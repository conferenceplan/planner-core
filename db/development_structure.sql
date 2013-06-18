CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `addressable_id` int(11) DEFAULT NULL,
  `addressable_type` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `isvalid` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `addr_id_index` (`addressable_id`),
  KEY `addr_type_index` (`addressable_type`),
  KEY `addr_person_id_index` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5997 DEFAULT CHARSET=utf8;

CREATE TABLE `answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Survey_id` int(11) DEFAULT NULL,
  `question` varchar(255) DEFAULT NULL,
  `reply` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auditable_id` int(11) DEFAULT NULL,
  `auditable_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `changes` text,
  `version` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `user_index` (`user_id`,`user_type`),
  KEY `index_audits_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=24848 DEFAULT CHARSET=utf8;

CREATE TABLE `available_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `change_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `who` varchar(255) DEFAULT NULL,
  `when` datetime DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `datasources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `edited_bios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bio` text,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `website` text,
  `twitterinfo` text,
  `othersocialmedia` text,
  `photourl` text,
  `facebook` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `email_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT '',
  `isdefault` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3048 DEFAULT CHARSET=utf8;

CREATE TABLE `enumrecord` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

CREATE TABLE `equipment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `details` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `equipment_type_id` int(11) DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `equipment_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `programme_item_id` int(11) DEFAULT NULL,
  `equipment_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `equipment_needs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `programme_item_id` int(11) DEFAULT NULL,
  `equipment_type_id` int(11) DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `equip_item_id_index` (`programme_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `equipment_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `excluded_items_survey_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `programme_item_id` int(11) DEFAULT NULL,
  `mapped_survey_question_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `excluded_periods_survey_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `period_id` int(11) DEFAULT NULL,
  `period_type` varchar(255) DEFAULT NULL,
  `survey_question` text,
  `survey_code` text,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `exclusions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `excludable_id` int(11) DEFAULT NULL,
  `excludable_type` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `source` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `formats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;

CREATE TABLE `invitation_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conference_name` varchar(255) DEFAULT '',
  `cc` varchar(255) DEFAULT '',
  `from` varchar(255) DEFAULT '',
  `domain` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `info` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `mail_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mail_use_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT '',
  `subject` varchar(255) DEFAULT '',
  `content` text,
  `survey_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

CREATE TABLE `mapped_survey_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question` text,
  `code` text,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

CREATE TABLE `menu_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `path` varchar(255) DEFAULT '/',
  `menu_id` int(11) DEFAULT NULL,
  `menu_item_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8;

CREATE TABLE `menus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `message` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `pending_import_people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT '',
  `last_name` varchar(255) DEFAULT '',
  `suffix` varchar(255) DEFAULT '',
  `line1` varchar(255) DEFAULT NULL,
  `line2` varchar(255) DEFAULT NULL,
  `line3` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT '',
  `registration_number` varchar(255) DEFAULT NULL,
  `registration_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `datasource_id` int(11) DEFAULT NULL,
  `datasource_dbid` int(11) DEFAULT NULL,
  `pendingtype_id` int(11) DEFAULT NULL,
  `alt_email` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3177 DEFAULT CHARSET=utf8;

CREATE TABLE `pending_publication_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `programme_item_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT '',
  `last_name` varchar(255) DEFAULT '',
  `suffix` varchar(255) DEFAULT '',
  `language` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `invitestatus_id` int(11) DEFAULT NULL,
  `invitation_category_id` int(11) DEFAULT NULL,
  `acceptance_status_id` int(11) DEFAULT NULL,
  `mailing_number` int(11) DEFAULT NULL,
  `comments` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2624 DEFAULT CHARSET=utf8;

CREATE TABLE `peoplesources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `datasource_id` int(11) DEFAULT NULL,
  `datasource_dbid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2624 DEFAULT CHARSET=utf8;

CREATE TABLE `phone_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT '',
  `phone_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=utf8;

CREATE TABLE `postal_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `line1` varchar(255) DEFAULT NULL,
  `line2` varchar(255) DEFAULT NULL,
  `line3` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `isdefault` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2738 DEFAULT CHARSET=utf8;

CREATE TABLE `preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `receive_messages` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `programme_item_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `role_id` int(11) DEFAULT NULL,
  `programme_item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pia_person_index` (`person_id`),
  KEY `pis_prog_item_id_index` (`programme_item_id`),
  KEY `pia_role_id_index` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1680 DEFAULT CHARSET=utf8;

CREATE TABLE `programme_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `short_title` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `precis` text,
  `duration` int(11) DEFAULT NULL,
  `minimum_people` int(11) DEFAULT NULL,
  `maximum_people` int(11) DEFAULT NULL,
  `notes` text,
  `print` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `format_id` int(11) DEFAULT NULL,
  `setup_type_id` int(11) DEFAULT NULL,
  `pub_reference_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=656 DEFAULT CHARSET=utf8;

CREATE TABLE `pseudonyms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT '',
  `last_name` varchar(255) DEFAULT '',
  `suffix` varchar(255) DEFAULT '',
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `pseudonym_person_index` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8;

CREATE TABLE `publication_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `newitems` int(11) DEFAULT '0',
  `modifieditems` int(11) DEFAULT '0',
  `removeditems` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `publications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_id` int(11) DEFAULT NULL,
  `published_type` varchar(255) DEFAULT NULL,
  `original_id` int(11) DEFAULT NULL,
  `original_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `publication_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `pub_pub_id_type_index` (`published_id`,`published_type`),
  KEY `pub_original_id_type_index` (`original_id`,`original_type`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;

CREATE TABLE `published_programme_item_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_programme_item_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `role_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pub_progitem_assignment_item_index` (`published_programme_item_id`),
  KEY `pub_progitem_assignment_person_index` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8;

CREATE TABLE `published_programme_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `short_title` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `precis` text,
  `duration` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `format_id` int(11) DEFAULT NULL,
  `pub_reference_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8;

CREATE TABLE `published_room_item_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_room_id` int(11) DEFAULT NULL,
  `published_programme_item_id` int(11) DEFAULT NULL,
  `published_time_slot_id` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT '-1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `pub_room_assign_room_index` (`published_room_id`),
  KEY `pub_room_assign_item_index` (`published_programme_item_id`),
  KEY `pub_room_assign_time_index` (`published_time_slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8;

CREATE TABLE `published_rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_venue_id` int(11) DEFAULT NULL,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

CREATE TABLE `published_time_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8;

CREATE TABLE `published_venues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `registration_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `registration_number` varchar(255) DEFAULT NULL,
  `registration_type` varchar(255) DEFAULT NULL,
  `registered` tinyint(1) DEFAULT NULL,
  `ghost` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1985 DEFAULT CHARSET=utf8;

CREATE TABLE `relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `relatable_id` int(11) DEFAULT NULL,
  `relatable_type` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `relationship_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `role_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=183 DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `room_item_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_id` int(11) DEFAULT NULL,
  `programme_item_id` int(11) DEFAULT NULL,
  `time_slot_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `day` int(11) DEFAULT '-1',
  PRIMARY KEY (`id`),
  KEY `ria_room_id_index` (`room_id`),
  KEY `ria_prog_item_id_index` (`programme_item_id`),
  KEY `ria_time_slot_id_index` (`time_slot_id`),
  KEY `ria_day_index` (`day`)
) ENGINE=InnoDB AUTO_INCREMENT=309 DEFAULT CHARSET=utf8;

CREATE TABLE `room_setups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_id` int(11) DEFAULT NULL,
  `setup_type_id` int(11) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8;

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `venue_id` int(11) DEFAULT NULL,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `purpose` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `setup_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `setup_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `smerf_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `active` int(11) NOT NULL,
  `cache` mediumtext,
  `cache_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_smerf_forms_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `smerf_forms_surveyrespondents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `surveyrespondent_id` int(11) NOT NULL,
  `smerf_form_id` int(11) NOT NULL,
  `responses` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `smerf_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `smerf_forms_surveyrespondent_id` int(11) NOT NULL,
  `question_code` varchar(255) NOT NULL,
  `response` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer` text,
  `default` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `survey_question_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `help` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `person_id` int(11) DEFAULT NULL,
  `survey_response_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_copy_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `survey_respondent_id` int(11) DEFAULT NULL,
  `nameCopied` tinyint(1) DEFAULT '0',
  `pseudonymCopied` tinyint(1) DEFAULT '0',
  `addressCopied` tinyint(1) DEFAULT '0',
  `phoneCopied` tinyint(1) DEFAULT '0',
  `emailCopied` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `tagsCopied` tinyint(1) DEFAULT '0',
  `availableDatesCopied` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `survey_formats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `help` text,
  `style` varchar(255) DEFAULT '',
  `description_style` varchar(255) DEFAULT '',
  `answer_style` varchar(255) DEFAULT '',
  `question_style` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `formatable_id` int(11) DEFAULT NULL,
  `formatable_type` varchar(255) DEFAULT NULL,
  `help1` text,
  `help2` text,
  `help3` text,
  `help4` text,
  `help5` text,
  `help6` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT '',
  `name` varchar(255) DEFAULT '',
  `altname` varchar(255) DEFAULT '',
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `survey_id` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `operation` varchar(255) DEFAULT NULL,
  `survey_id` int(11) DEFAULT NULL,
  `shared` tinyint(1) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

CREATE TABLE `survey_query_predicates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `survey_question_id` int(11) DEFAULT NULL,
  `operation` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `survey_query_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

CREATE TABLE `survey_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT '',
  `title` varchar(255) DEFAULT '',
  `question` text,
  `tags_label` varchar(255) DEFAULT '',
  `question_type` varchar(255) DEFAULT 'textfield',
  `additional` int(11) DEFAULT '0',
  `validation` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `survey_group_id` int(11) DEFAULT NULL,
  `mandatory` tinyint(1) DEFAULT '0',
  `text_size` int(11) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `answer_type` varchar(255) DEFAULT 'String',
  `answer1_type` varchar(255) DEFAULT 'String',
  `question1` text,
  `answer2_type` varchar(255) DEFAULT 'String',
  `question2` text,
  `answer3_type` varchar(255) DEFAULT 'String',
  `question3` text,
  `answer4_type` varchar(255) DEFAULT 'String',
  `question4` text,
  `answer5_type` varchar(255) DEFAULT 'String',
  `question5` text,
  `answer6_type` varchar(255) DEFAULT 'String',
  `question6` text,
  `isbio` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_respondent_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT '',
  `last_name` varchar(255) DEFAULT '',
  `suffix` varchar(255) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `survey_respondent_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=596 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_respondents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `single_access_token` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `attending` tinyint(1) DEFAULT '1',
  `person_id` int(11) DEFAULT NULL,
  `submitted_survey` tinyint(1) DEFAULT '0',
  `email_status_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=742 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `response` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `survey_id` int(11) DEFAULT NULL,
  `survey_question_id` int(11) DEFAULT NULL,
  `survey_respondent_detail_id` int(11) DEFAULT NULL,
  `response1` text,
  `response2` text,
  `response3` text,
  `response4` text,
  `response5` text,
  `response6` text,
  `isbio` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16202 DEFAULT CHARSET=utf8;

CREATE TABLE `survey_sub_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `survey_question_id` int(11) DEFAULT NULL,
  `survey_answer_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `surveys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `welcome` text,
  `thank_you` text,
  `alias` varchar(255) DEFAULT '',
  `submit_string` varchar(255) DEFAULT 'Save',
  `header_image` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `tag_contexts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) DEFAULT NULL,
  `taggable_type` varchar(255) DEFAULT NULL,
  `context` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`)
) ENGINE=InnoDB AUTO_INCREMENT=8826 DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1258 DEFAULT CHARSET=utf8;

CREATE TABLE `time_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `time_slot_start_index` (`start`),
  KEY `time_slot_end_index` (`end`)
) ENGINE=InnoDB AUTO_INCREMENT=309 DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) NOT NULL,
  `crypted_password` varchar(255) NOT NULL,
  `password_salt` varchar(255) NOT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `single_access_token` varchar(255) NOT NULL,
  `perishable_token` varchar(255) NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;

CREATE TABLE `venues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20100206172839');

INSERT INTO schema_migrations (version) VALUES ('20100206174234');

INSERT INTO schema_migrations (version) VALUES ('20100206181707');

INSERT INTO schema_migrations (version) VALUES ('20100206184135');

INSERT INTO schema_migrations (version) VALUES ('20100206200809');

INSERT INTO schema_migrations (version) VALUES ('20100206203032');

INSERT INTO schema_migrations (version) VALUES ('20100206214318');

INSERT INTO schema_migrations (version) VALUES ('20100206214347');

INSERT INTO schema_migrations (version) VALUES ('20100207003248');

INSERT INTO schema_migrations (version) VALUES ('20100207003257');

INSERT INTO schema_migrations (version) VALUES ('20100221183506');

INSERT INTO schema_migrations (version) VALUES ('20100501191445');

INSERT INTO schema_migrations (version) VALUES ('20100502233451');

INSERT INTO schema_migrations (version) VALUES ('20100504233253');

INSERT INTO schema_migrations (version) VALUES ('20100504233536');

INSERT INTO schema_migrations (version) VALUES ('20100505114921');

INSERT INTO schema_migrations (version) VALUES ('20100505115003');

INSERT INTO schema_migrations (version) VALUES ('20100508171212');

INSERT INTO schema_migrations (version) VALUES ('20100508171254');

INSERT INTO schema_migrations (version) VALUES ('20100607060740');

INSERT INTO schema_migrations (version) VALUES ('20100627184128');

INSERT INTO schema_migrations (version) VALUES ('20100816044026');

INSERT INTO schema_migrations (version) VALUES ('20100816052247');

INSERT INTO schema_migrations (version) VALUES ('20100912011457');

INSERT INTO schema_migrations (version) VALUES ('20100926221757');

INSERT INTO schema_migrations (version) VALUES ('20100926224230');

INSERT INTO schema_migrations (version) VALUES ('20100930060100');

INSERT INTO schema_migrations (version) VALUES ('20101010200615');

INSERT INTO schema_migrations (version) VALUES ('20101017204221');

INSERT INTO schema_migrations (version) VALUES ('20101017205638');

INSERT INTO schema_migrations (version) VALUES ('20101023231210');

INSERT INTO schema_migrations (version) VALUES ('20101116060730');

INSERT INTO schema_migrations (version) VALUES ('20101128213629');

INSERT INTO schema_migrations (version) VALUES ('20101201061202');

INSERT INTO schema_migrations (version) VALUES ('20101212014850');

INSERT INTO schema_migrations (version) VALUES ('20101212022005');

INSERT INTO schema_migrations (version) VALUES ('20101214071536');

INSERT INTO schema_migrations (version) VALUES ('20101216071519');

INSERT INTO schema_migrations (version) VALUES ('20101219195447');

INSERT INTO schema_migrations (version) VALUES ('20101220005701');

INSERT INTO schema_migrations (version) VALUES ('20101227161005');

INSERT INTO schema_migrations (version) VALUES ('20101228213222');

INSERT INTO schema_migrations (version) VALUES ('20101229172648');

INSERT INTO schema_migrations (version) VALUES ('20101229173903');

INSERT INTO schema_migrations (version) VALUES ('20101229213216');

INSERT INTO schema_migrations (version) VALUES ('20110102004619');

INSERT INTO schema_migrations (version) VALUES ('20110102144749');

INSERT INTO schema_migrations (version) VALUES ('20110106065240');

INSERT INTO schema_migrations (version) VALUES ('20110124034452');

INSERT INTO schema_migrations (version) VALUES ('20110125061216');

INSERT INTO schema_migrations (version) VALUES ('20110130065419');

INSERT INTO schema_migrations (version) VALUES ('20110206185746');

INSERT INTO schema_migrations (version) VALUES ('20110209021239');

INSERT INTO schema_migrations (version) VALUES ('20110215183554');

INSERT INTO schema_migrations (version) VALUES ('20110218003337');

INSERT INTO schema_migrations (version) VALUES ('20110218010642');

INSERT INTO schema_migrations (version) VALUES ('20110219021921');

INSERT INTO schema_migrations (version) VALUES ('20110219022211');

INSERT INTO schema_migrations (version) VALUES ('20110219024847');

INSERT INTO schema_migrations (version) VALUES ('20110219174507');

INSERT INTO schema_migrations (version) VALUES ('20110221034135');

INSERT INTO schema_migrations (version) VALUES ('20110222030741');

INSERT INTO schema_migrations (version) VALUES ('20110224032331');

INSERT INTO schema_migrations (version) VALUES ('20110227183006');

INSERT INTO schema_migrations (version) VALUES ('20110301054359');

INSERT INTO schema_migrations (version) VALUES ('20110303161758');

INSERT INTO schema_migrations (version) VALUES ('20110306025816');

INSERT INTO schema_migrations (version) VALUES ('20110306155804');

INSERT INTO schema_migrations (version) VALUES ('20110306161408');

INSERT INTO schema_migrations (version) VALUES ('20110311175106');

INSERT INTO schema_migrations (version) VALUES ('20110313144015');

INSERT INTO schema_migrations (version) VALUES ('20110313144655');

INSERT INTO schema_migrations (version) VALUES ('20110313172244');

INSERT INTO schema_migrations (version) VALUES ('20110313190430');

INSERT INTO schema_migrations (version) VALUES ('20110314000235');

INSERT INTO schema_migrations (version) VALUES ('20110314014503');

INSERT INTO schema_migrations (version) VALUES ('20110323074227');

INSERT INTO schema_migrations (version) VALUES ('20110324203306');

INSERT INTO schema_migrations (version) VALUES ('20110325153114');

INSERT INTO schema_migrations (version) VALUES ('20110326034420');

INSERT INTO schema_migrations (version) VALUES ('20110327084410');

INSERT INTO schema_migrations (version) VALUES ('20110329155605');

INSERT INTO schema_migrations (version) VALUES ('20110330175723');

INSERT INTO schema_migrations (version) VALUES ('20110331175119');

INSERT INTO schema_migrations (version) VALUES ('20110401141631');

INSERT INTO schema_migrations (version) VALUES ('20110402194740');

INSERT INTO schema_migrations (version) VALUES ('20110404182152');

INSERT INTO schema_migrations (version) VALUES ('20110408160536');

INSERT INTO schema_migrations (version) VALUES ('20110409161512');

INSERT INTO schema_migrations (version) VALUES ('20110410003645');

INSERT INTO schema_migrations (version) VALUES ('20110410084841');

INSERT INTO schema_migrations (version) VALUES ('20110411053229');

INSERT INTO schema_migrations (version) VALUES ('20110411133310');

INSERT INTO schema_migrations (version) VALUES ('20110411233609');

INSERT INTO schema_migrations (version) VALUES ('20110414180432');

INSERT INTO schema_migrations (version) VALUES ('20110414203046');

INSERT INTO schema_migrations (version) VALUES ('20110417212506');

INSERT INTO schema_migrations (version) VALUES ('20110423154044');

INSERT INTO schema_migrations (version) VALUES ('20110423200915');

INSERT INTO schema_migrations (version) VALUES ('20110424183843');

INSERT INTO schema_migrations (version) VALUES ('20110426042131');

INSERT INTO schema_migrations (version) VALUES ('20110426102418');

INSERT INTO schema_migrations (version) VALUES ('20110426113730');

INSERT INTO schema_migrations (version) VALUES ('20110429230615');

INSERT INTO schema_migrations (version) VALUES ('20110429231411');

INSERT INTO schema_migrations (version) VALUES ('20110429233606');

INSERT INTO schema_migrations (version) VALUES ('20110430021635');

INSERT INTO schema_migrations (version) VALUES ('20110430021709');

INSERT INTO schema_migrations (version) VALUES ('20110430021753');

INSERT INTO schema_migrations (version) VALUES ('20110430021832');

INSERT INTO schema_migrations (version) VALUES ('20110430021855');

INSERT INTO schema_migrations (version) VALUES ('20110430214342');

INSERT INTO schema_migrations (version) VALUES ('20110502032520');

INSERT INTO schema_migrations (version) VALUES ('20110502040231');

INSERT INTO schema_migrations (version) VALUES ('20110507225952');

INSERT INTO schema_migrations (version) VALUES ('20110508034855');

INSERT INTO schema_migrations (version) VALUES ('20110508055700');

INSERT INTO schema_migrations (version) VALUES ('20110508144939');

INSERT INTO schema_migrations (version) VALUES ('20110512023057');

INSERT INTO schema_migrations (version) VALUES ('20110512051422');

INSERT INTO schema_migrations (version) VALUES ('20110512165849');

INSERT INTO schema_migrations (version) VALUES ('20110523035306');

INSERT INTO schema_migrations (version) VALUES ('20110523150458');

INSERT INTO schema_migrations (version) VALUES ('20110605002129');

INSERT INTO schema_migrations (version) VALUES ('20110609023359');

INSERT INTO schema_migrations (version) VALUES ('20110611124142');

INSERT INTO schema_migrations (version) VALUES ('20110611124625');

INSERT INTO schema_migrations (version) VALUES ('20110611124850');

INSERT INTO schema_migrations (version) VALUES ('20110611125913');

INSERT INTO schema_migrations (version) VALUES ('20110612082224');

INSERT INTO schema_migrations (version) VALUES ('20110619060820');

INSERT INTO schema_migrations (version) VALUES ('20110620042329');

INSERT INTO schema_migrations (version) VALUES ('20110620045911');

INSERT INTO schema_migrations (version) VALUES ('20110625182734');

INSERT INTO schema_migrations (version) VALUES ('20110701024156');

INSERT INTO schema_migrations (version) VALUES ('20110702010649');

INSERT INTO schema_migrations (version) VALUES ('20110702221809');

INSERT INTO schema_migrations (version) VALUES ('20110709134016');

INSERT INTO schema_migrations (version) VALUES ('20110711041542');

INSERT INTO schema_migrations (version) VALUES ('20110724072909');

INSERT INTO schema_migrations (version) VALUES ('20110725022722');

INSERT INTO schema_migrations (version) VALUES ('20110725112036');

INSERT INTO schema_migrations (version) VALUES ('20110727015515');

INSERT INTO schema_migrations (version) VALUES ('20110728181631');

INSERT INTO schema_migrations (version) VALUES ('20110729173548');

INSERT INTO schema_migrations (version) VALUES ('20110730155403');

INSERT INTO schema_migrations (version) VALUES ('20110731171443');

INSERT INTO schema_migrations (version) VALUES ('20110801055317');

INSERT INTO schema_migrations (version) VALUES ('20110802020809');

INSERT INTO schema_migrations (version) VALUES ('20110803073129');

INSERT INTO schema_migrations (version) VALUES ('20110807054713');

INSERT INTO schema_migrations (version) VALUES ('20120129153515');

INSERT INTO schema_migrations (version) VALUES ('20120129181758');

INSERT INTO schema_migrations (version) VALUES ('20120204162017');

INSERT INTO schema_migrations (version) VALUES ('20120204162028');

INSERT INTO schema_migrations (version) VALUES ('20120204164225');

INSERT INTO schema_migrations (version) VALUES ('20120213020550');

INSERT INTO schema_migrations (version) VALUES ('20120213021913');

INSERT INTO schema_migrations (version) VALUES ('20120213031438');

INSERT INTO schema_migrations (version) VALUES ('20120310204559');

INSERT INTO schema_migrations (version) VALUES ('20120407182132');

INSERT INTO schema_migrations (version) VALUES ('20120522140924');

INSERT INTO schema_migrations (version) VALUES ('20120630215440');

INSERT INTO schema_migrations (version) VALUES ('20120630221320');

INSERT INTO schema_migrations (version) VALUES ('20120701191431');

INSERT INTO schema_migrations (version) VALUES ('20120714235310');

INSERT INTO schema_migrations (version) VALUES ('20120723023207');

INSERT INTO schema_migrations (version) VALUES ('20120729231456');

INSERT INTO schema_migrations (version) VALUES ('20120812225700');

INSERT INTO schema_migrations (version) VALUES ('20120909191124');

INSERT INTO schema_migrations (version) VALUES ('20120922191655');

INSERT INTO schema_migrations (version) VALUES ('20120929142521');

INSERT INTO schema_migrations (version) VALUES ('20121003011745');

INSERT INTO schema_migrations (version) VALUES ('20121004001002');

INSERT INTO schema_migrations (version) VALUES ('20121008011259');

INSERT INTO schema_migrations (version) VALUES ('20121207214719');

INSERT INTO schema_migrations (version) VALUES ('20121209170101');

INSERT INTO schema_migrations (version) VALUES ('20121209235219');

INSERT INTO schema_migrations (version) VALUES ('20130106205709');

INSERT INTO schema_migrations (version) VALUES ('20130126211521');

INSERT INTO schema_migrations (version) VALUES ('20130127185556');

INSERT INTO schema_migrations (version) VALUES ('20130309173348');

INSERT INTO schema_migrations (version) VALUES ('20130309174000');

INSERT INTO schema_migrations (version) VALUES ('20130317222226');