export const playerColors = ['coral', 'sapphire', 'jade', 'gold'] as const;
export type PlayerColor = (typeof playerColors)[number];
export type MatchPhase = 'rolling' | 'selectingPawn' | 'finished';
export type ServerGameMode = 'classic' | 'quick';

export interface TrustedMatchConfig {
  mode: ServerGameMode;
}

export interface TrustedPawn {
  id: string;
  color: PlayerColor;
  progress: number;
}

export interface TrustedPlayer {
  userId: string;
  color: PlayerColor;
  pawns: TrustedPawn[];
}

export interface TrustedMatchState {
  id: string;
  roomId: string;
  config: TrustedMatchConfig;
  players: TrustedPlayer[];
  currentPlayerIndex: number;
  phase: MatchPhase;
  dice: number | null;
  winner: PlayerColor | null;
  revision: number;
  message: string;
}

export interface MatchEvent {
  revision: number;
  kind: 'match_started' | 'dice_rolled' | 'pawn_moved' | 'turn_skipped' | 'match_finished';
  actorUserId: string;
  atMilliseconds: number;
  details: Record<string, string | number | boolean | null>;
}

export interface TrustedRoom {
  id: string;
  code: string;
  hostUserId: string;
  maxPlayers: 2 | 3 | 4;
  config: TrustedMatchConfig;
  playerIds: string[];
  status: 'waiting' | 'playing' | 'finished';
  matchId: string | null;
}
