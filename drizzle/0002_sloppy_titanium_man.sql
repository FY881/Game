CREATE TABLE `nexus_architect_config` (
	`id` int AUTO_INCREMENT NOT NULL,
	`enabled` int NOT NULL DEFAULT 1,
	`cadenceMinutes` int NOT NULL DEFAULT 15,
	`scheduleCronTaskUid` varchar(65),
	`lastRunAt` timestamp,
	`lastStatus` varchar(24),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `nexus_architect_config_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_architect_config_scheduleCronTaskUid_unique` UNIQUE(`scheduleCronTaskUid`)
);
--> statement-breakpoint
CREATE TABLE `nexus_architect_runs` (
	`id` int AUTO_INCREMENT NOT NULL,
	`configId` int NOT NULL,
	`runKey` varchar(48) NOT NULL,
	`status` varchar(24) NOT NULL,
	`healthScore` int NOT NULL,
	`recommendations` text NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `nexus_architect_runs_id` PRIMARY KEY(`id`),
	CONSTRAINT `nexus_architect_runs_runKey_unique` UNIQUE(`runKey`)
);
--> statement-breakpoint
CREATE INDEX `nexus_architect_task_uid_idx` ON `nexus_architect_config` (`scheduleCronTaskUid`);--> statement-breakpoint
CREATE INDEX `nexus_architect_run_config_idx` ON `nexus_architect_runs` (`configId`,`createdAt`);