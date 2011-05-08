CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `addressable_id` int(11) DEFAULT NULL,
  `addressable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `isvalid` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52138 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Survey_id` int(11) DEFAULT NULL,
  `question` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reply` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=6954 DEFAULT CHARSET=latin1;

CREATE TABLE `available_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=322 DEFAULT CHARSET=latin1;

CREATE TABLE `change_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `who` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `when` datetime DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `old_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=356 DEFAULT CHARSET=latin1;

CREATE TABLE `email_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `isdefault` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12374 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `enumrecord` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `excluded_items_survey_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `programme_item_id` int(11) DEFAULT NULL,
  `mapped_survey_question_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `exclusions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `excludable_id` int(11) DEFAULT NULL,
  `excludable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `source` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `formats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1;

CREATE TABLE `invitation_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mapped_survey_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question` text,
  `code` text,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;

CREATE TABLE `menu_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT '/',
  `menu_id` int(11) DEFAULT NULL,
  `menu_item_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `menus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `message` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `pending_import_people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suffix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `line1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `line2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `line3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `postcode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(2) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30568 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suffix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `invitestatus_id` int(11) DEFAULT NULL,
  `invitation_category_id` int(11) DEFAULT NULL,
  `acceptance_status_id` int(11) DEFAULT NULL,
  `mailing_number` int(11) DEFAULT NULL,
  `comments` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29528 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `phone_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT '',
  `phone_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10856 DEFAULT CHARSET=latin1;

CREATE TABLE `postal_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `line1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `line2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `line3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `postcode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `isdefault` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28910 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `receive_messages` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB AUTO_INCREMENT=1467 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `programme_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `short_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `precis` text COLLATE utf8_unicode_ci,
  `duration` int(11) DEFAULT NULL,
  `minimum_people` int(11) DEFAULT NULL,
  `maximum_people` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `print` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `format_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=655 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `pseudonyms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suffix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `published_programme_item_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_person_id` int(11) DEFAULT NULL,
  `published_programme_item_id` int(11) DEFAULT NULL,
  `role` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `published_programme_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `short_title` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `precis` text,
  `duration` int(11) DEFAULT NULL,
  `format` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `published_publications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_id` int(11) DEFAULT NULL,
  `published_type` varchar(255) DEFAULT NULL,
  `original_id` int(11) DEFAULT NULL,
  `original_type` varchar(255) DEFAULT NULL,
  `User_id` int(11) DEFAULT NULL,
  `publication_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `published_room_item_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_room_id` int(11) DEFAULT NULL,
  `published_programme_item_id` int(11) DEFAULT NULL,
  `published_time_slot_id` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT '-1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `published_rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published_venue_id` int(11) DEFAULT NULL,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `published_time_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `published_venues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `registration_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `registration_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registration_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `registered` tinyint(1) DEFAULT NULL,
  `ghost` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2252 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `relatable_id` int(11) DEFAULT NULL,
  `relatable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `relationship_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `role_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `room_free_times` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_id` int(11) DEFAULT NULL,
  `time_slot_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `day` int(11) DEFAULT '-1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB AUTO_INCREMENT=485 DEFAULT CHARSET=latin1;

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `venue_id` int(11) DEFAULT NULL,
  `name` text COLLATE utf8_unicode_ci,
  `capacity` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  `purpose` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`version`),
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `smerf_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `active` int(11) NOT NULL,
  `cache` longtext COLLATE utf8_unicode_ci,
  `cache_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_smerf_forms_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `smerf_forms_surveyrespondents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `surveyrespondent_id` int(11) NOT NULL,
  `smerf_form_id` int(11) NOT NULL,
  `responses` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=351 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `smerf_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `smerf_forms_surveyrespondent_id` int(11) NOT NULL,
  `question_code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `response` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12087 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=latin1;

CREATE TABLE `survey_respondents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `prefix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `persistence_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `single_access_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `attending` tinyint(1) DEFAULT '1',
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `suffix` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `submitted_survey` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=780 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `surveys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Person_id` int(11) DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `can_interview` tinyint(1) DEFAULT NULL,
  `hugo_nominee` tinyint(1) DEFAULT NULL,
  `volunteer` tinyint(1) DEFAULT NULL,
  `arrival_time` datetime DEFAULT NULL,
  `departure_time` datetime DEFAULT NULL,
  `max_items` int(11) DEFAULT NULL,
  `max_items_per_day` int(11) DEFAULT NULL,
  `nbr_panels_moderated` int(11) DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tag_contexts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `context` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `taggables_idx` (`taggable_id`),
  KEY `tagger_idx` (`tagger_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8899 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1305 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `time_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `time_slot_start_index` (`start`),
  KEY `time_slot_end_index` (`end`)
) ENGINE=InnoDB AUTO_INCREMENT=485 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `crypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `persistence_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `single_access_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `perishable_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_login_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `venues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `lock_version` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20100206172839');

INSERT INTO schema_migrations (version) VALUES ('20100206174234');

INSERT INTO schema_migrations (version) VALUES ('20100206181707');

INSERT INTO schema_migrations (version) VALUES ('20100206184135');

INSERT INTO schema_migrations (version) VALUES ('20100206200809');

INSERT INTO schema_migrations (version) VALUES ('20100206203032');

INSERT INTO schema_migrations (version) VALUES ('20100206214318');

INSERT INTO schema_migrations (version) VALUES ('20100206214347');

INSERT INTO schema_migrations (version) VALUES ('20100206224158');

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

INSERT INTO schema_migrations (version) VALUES ('20110320111152');

INSERT INTO schema_migrations (version) VALUES ('20110323074227');

INSERT INTO schema_migrations (version) VALUES ('20110324203306');

INSERT INTO schema_migrations (version) VALUES ('20110325153114');

INSERT INTO schema_migrations (version) VALUES ('20110326034420');

INSERT INTO schema_migrations (version) VALUES ('20110327084410');

INSERT INTO schema_migrations (version) VALUES ('20110327085142');

INSERT INTO schema_migrations (version) VALUES ('20110329155605');

INSERT INTO schema_migrations (version) VALUES ('20110330175723');

INSERT INTO schema_migrations (version) VALUES ('20110331175119');

INSERT INTO schema_migrations (version) VALUES ('20110401141631');

INSERT INTO schema_migrations (version) VALUES ('20110402194740');

INSERT INTO schema_migrations (version) VALUES ('20110404182152');

INSERT INTO schema_migrations (version) VALUES ('20110407180927');

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

INSERT INTO schema_migrations (version) VALUES ('20110424183843');

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