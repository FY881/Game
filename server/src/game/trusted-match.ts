import { randomInt, randomUUID } from 'node:crypto';

import type { MatchEvent, PlayerColor, TrustedMatchConfig, TrustedMatchState, TrustedPawn, TrustedPlayer } from './types.js';
import { playerColors } from './types.js';

const trackLength = 52;
const safeTrackIndices = new Set<number>([0, 8, 13, 21, 26, 34, 39, 47]);
const startOffsets: Record<PlayerColor, number> = { coral: 0, sapphire: 13, jade: 26, gold: 39 };

export class MatchFailure extends Error {
  constructor(public readonly code: string) {
    super(code);
  }
}

export class TrustedMatch {
  private stateValue: TrustedMatchState;
  private readonly eventLog: MatchEvent[] = [];

  constructor(
    roomId: string,
    userIds: string[],
    config: TrustedMatchConfig,
    private readonly rollDie: () => number = () => randomInt(1, 7),
    private readonly now: () => number = () => Date.now(),
  ) {
    if (userIds.length < 2 || userIds.length > 4) throw new MatchFailure('PLAYER_COUNT_INVALID');
    if (new Set(userIds).size !== userIds.length) throw new MatchFailure('DUPLICATE_PLAYER');
    const pawnsPerPlayer = config.mode === 'quick' ? 3 : 4;
    const players: TrustedPlayer[] = userIds.map((userId, index) => {
      const color = playerColors[index];
      return {
        userId,
        color,
        pawns: Array.from({ length: pawnsPerPlayer }, (_, pawnIndex) => ({ id: `${color}-${pawnIndex}`, color, progress: -1 })),
      };
    });
    this.stateValue = {
      id: `match_${randomUUID()}`,
      roomId,
      config,
      players,
      currentPlayerIndex: 0,
      phase: 'rolling',
      dice: null,
      winner: null,
      revision: 0,
      message: 'المباراة بدأت. دور اللاعب الأول لرمي النرد.',
    };
    this.appendEvent('match_started', userIds[0], { playerCount: userIds.length, mode: config.mode });
  }

  get state(): TrustedMatchState {
    return structuredClone(this.stateValue);
  }

  get events(): MatchEvent[] {
    return structuredClone(this.eventLog);
  }

  requestRoll(userId: string): TrustedMatchState {
    this.requireCurrentUser(userId);
    if (this.stateValue.phase !== 'rolling') throw new MatchFailure('ROLL_NOT_ALLOWED');
    const dice = this.rollDie();
    if (!Number.isInteger(dice) || dice < 1 || dice > 6) throw new MatchFailure('SERVER_RANDOM_INVALID');
    this.stateValue.dice = dice;
    this.stateValue.phase = 'selectingPawn';
    this.stateValue.message = `رمى الخادم النرد: ${dice}.`;
    this.appendEvent('dice_rolled', userId, { dice });
    if (this.legalPawnIds().length === 0) this.finishTurn(userId, 'لا توجد حركة قانونية لهذه الرمية.', 'turn_skipped');
    return this.state;
  }

  requestMove(userId: string, pawnId: string): TrustedMatchState {
    this.requireCurrentUser(userId);
    if (this.stateValue.phase !== 'selectingPawn' || this.stateValue.dice === null) throw new MatchFailure('MOVE_NOT_ALLOWED');
    if (!this.legalPawnIds().includes(pawnId)) throw new MatchFailure('PAWN_MOVE_ILLEGAL');
    const activePlayer = this.activePlayer;
    const pawnIndex = activePlayer.pawns.findIndex((pawn) => pawn.id === pawnId);
    const selected = activePlayer.pawns[pawnIndex];
    const dice = this.stateValue.dice;
    const nextProgress = selected.progress === -1 ? 0 : selected.progress + dice;
    activePlayer.pawns[pawnIndex] = { ...selected, progress: nextProgress };
    let message = `حرك الخادم الحجر ${dice} خانات.`;
    let captured = false;
    if (nextProgress < trackLength) {
      const destination = this.trackIndex(activePlayer.color, nextProgress);
      if (!safeTrackIndices.has(destination)) {
        for (const opponent of this.stateValue.players) {
          if (opponent.userId === userId) continue;
          opponent.pawns = opponent.pawns.map((pawn) => {
            if (pawn.progress >= 0 && pawn.progress < trackLength && this.trackIndex(opponent.color, pawn.progress) === destination) {
              captured = true;
              return { ...pawn, progress: -1 };
            }
            return pawn;
          });
        }
      }
    }
    if (captured) message = 'تمت إعادة حجر خصم إلى القاعدة.';
    if (activePlayer.pawns.every((pawn) => pawn.progress === this.homeProgress)) {
      this.stateValue.winner = activePlayer.color;
      this.stateValue.phase = 'finished';
      this.stateValue.message = `${activePlayer.color} فاز بالمباراة.`;
      this.appendEvent('match_finished', userId, { pawnId, dice, winner: activePlayer.color, captured });
      return this.state;
    }
    this.appendEvent('pawn_moved', userId, { pawnId, dice, captured, progress: nextProgress });
    this.finishTurn(userId, message, 'pawn_moved');
    return this.state;
  }

  legalPawnIds(): string[] {
    if (this.stateValue.phase !== 'selectingPawn' || this.stateValue.dice === null) return [];
    const dice = this.stateValue.dice;
    return this.activePlayer.pawns
      .filter((pawn) => (pawn.progress === -1 && this.canEnterWith(dice)) || (pawn.progress >= 0 && pawn.progress + dice <= this.homeProgress))
      .map((pawn) => pawn.id);
  }

  private get activePlayer(): TrustedPlayer {
    return this.stateValue.players[this.stateValue.currentPlayerIndex];
  }

  private get homeProgress(): number {
    return this.stateValue.config.mode === 'quick' ? 46 : 57;
  }

  private canEnterWith(dice: number): boolean {
    return this.stateValue.config.mode === 'quick' ? dice === 5 || dice === 6 : dice === 6;
  }

  private requireCurrentUser(userId: string): void {
    if (this.stateValue.winner) throw new MatchFailure('MATCH_FINISHED');
    if (this.activePlayer.userId !== userId) throw new MatchFailure('NOT_YOUR_TURN');
  }

  private finishTurn(actorUserId: string, message: string, eventKind: 'pawn_moved' | 'turn_skipped'): void {
    const bonusTurn = this.stateValue.dice === 6;
    if (!bonusTurn) this.stateValue.currentPlayerIndex = (this.stateValue.currentPlayerIndex + 1) % this.stateValue.players.length;
    this.stateValue.phase = 'rolling';
    this.stateValue.dice = null;
    this.stateValue.message = bonusTurn ? `${message} لك رمية إضافية.` : message;
    if (eventKind === 'turn_skipped') this.appendEvent('turn_skipped', actorUserId, { bonusTurn });
  }

  private trackIndex(color: PlayerColor, progress: number): number {
    return (startOffsets[color] + progress) % trackLength;
  }

  private appendEvent(kind: MatchEvent['kind'], actorUserId: string, details: MatchEvent['details']): void {
    this.stateValue.revision += 1;
    this.eventLog.push({ revision: this.stateValue.revision, kind, actorUserId, atMilliseconds: this.now(), details });
  }
}
