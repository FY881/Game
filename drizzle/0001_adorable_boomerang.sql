CREATE TABLE `nexus_arcade_scores` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`gameKey` varchar(48) NOT NULL,
	`score` int NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `nexus_arcade_scores_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `nexus_audit_logs` (
	`id` int AUTO_INCREMENT NOT NULL,
	`actorUserId` int,
	`eventType` varchar(64) NOT NULL,
	`payload` text NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `nexus_audit_logs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `nexus_clan_members` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clanId` int NOT NULL,
	`userId` int NOT NULL,
	`role` enum('leader','member') NOT NULL DEFAULT 'member',
	`joinedAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `nexus_clan_members_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_clan_members_userId_unique` UNIQUE(`userId`)
);
--> statement-breakpoint
CREATE TABLE `nexus_clans` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(32) NOT NULL,
	`ownerUserId` int NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `nexus_clans_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_clans_name_unique` UNIQUE(`name`)
);
--> statement-breakpoint
CREATE TABLE `nexus_settings` (
	`id` int AUTO_INCREMENT NOT NULL,
	`settingKey` varchar(64) NOT NULL,
	`settingValue` text NOT NULL,
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `nexus_settings_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_settings_settingKey_unique` UNIQUE(`settingKey`)
);
--> statement-breakpoint
CREATE TABLE `nexus_tournament_scores` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`weekKey` varchar(12) NOT NULL,
	`score` int NOT NULL DEFAULT 0,
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `nexus_tournament_scores_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_tournament_player_week_unique` UNIQUE(`userId`,`weekKey`)
);
--> statement-breakpoint
CREATE TABLE `nexus_wallets` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`gold` int NOT NULL DEFAULT 0,
	`gems` int NOT NULL DEFAULT 0,
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `nexus_wallets_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_wallets_userId_unique` UNIQUE(`userId`)
);
--> statement-breakpoint
CREATE INDEX `nexus_arcade_game_score_idx` ON `nexus_arcade_scores` (`gameKey`,`score`);--> statement-breakpoint
CREATE INDEX `nexus_arcade_player_game_idx` ON `nexus_arcade_scores` (`userId`,`gameKey`);--> statement-breakpoint
CREATE INDEX `nexus_audit_created_idx` ON `nexus_audit_logs` (`createdAt`);--> statement-breakpoint
CREATE INDEX `nexus_clan_membership_idx` ON `nexus_clan_members` (`clanId`);--> statement-breakpoint
CREATE INDEX `nexus_tournament_week_score_idx` ON `nexus_tournament_scores` (`weekKey`,`score`);