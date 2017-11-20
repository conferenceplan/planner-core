module Babel
  # A comment that someone submits about a model.
  # This can include ProgrammeItem, PublishedProgrammeItem, Document, etc.
  class Comment < ActiveRecord::Base
    ALLOWED_OWNERS = %w[Person User SupportUser].freeze
    ALLOWED_LINKS = %w[
      Person ProgrammeItem PublishedProgrammeItem PlannerDocs::Document
    ].freeze

    belongs_to :owner, polymorphic: true
    belongs_to :link, polymorphic: true
    belongs_to :deleted_by, polymorphic: true
    belongs_to :parent,
               class_name: 'Babel::Comment',
               foreign_key: 'parent_id'
    has_many :children,
             class_name: 'Babel::Comment'

    # TODO: Build module to generate relationships to Babel::Comment as
    # owner and link when included in a class

    validates :body, presence: true

    validates :owner_id, presence: true, numericality: { only_integer: true }
    validates :owner_type, presence: true, inclusion: { in: ALLOWED_OWNERS }
    validates :deleted_by_id,
              presence: true,
              numericality: { only_integer: true },
              if: :deleted?
    validates :deleted_by_type,
              presence: true,
              inclusion: { in: ALLOWED_OWNERS },
              if: :deleted?

    validates :link_id, presence: true, numericality: { only_integer: true }
    validates :link_type, presence: true, inclusion: { in: ALLOWED_LINKS }

    # TODO: Add enum for statuses

    # Add query scopes
    def self.deleted
      where.not(deleted_at: nil)
    end

    def self.not_deleted
      where(deleted_at: nil)
    end

    def self.not_deleted_by_owner
      # Exclude comments deleted by their owner
      deleted_at = arel_table[:deleted_at]
      deleted_by_id = arel_table[:deleted_by_id]
      deleted_by_type = arel_table[:deleted_by_type]
      owner_id = arel_table[:owner_id]

      deletion_query = deleted_at.eq(nil).or(
        deleted_by_id.not_eq(owner_id).and(
          deleted_by_type.eq('User').or(
            deleted_by_type.eq('SupportUser')
          )
        )
      )
      where(deletion_query)
    end

    def self.top_level
      where(parent_id: nil)
    end

    def self.by_date(dir: 'DESC')
      order("#{table_name}.created_at #{dir}")
    end

    def self.by_link_type
      order(:link_type)
    end

    def self.linked_to_pub_items
      linked_to('PublishedProgrammeItem')
    end

    def self.linked_to_items
      linked_to('ProgrammeItem')
    end

    # def self.linked_to_documents
    #   linked_to('PlannerDocs::Document')
    # end

    def self.linked_to(type, id: nil)
      # TODO: allow accepting array of ids
      link_type = arel_table[:link_type]
      link_id = arel_table[:link_id]
      link_query = link_type.eq(type)
      link_query = link_query.and(link_id.eq(id)) if id.present?

      where(link_query)
    end

    def self.owned_by(type, id: nil)
      owner_type = arel_table[:owner_type]
      owner_id = arel_table[:owner_id]
      owner_query = owner_type.eq(type)
      owner_query = owner_query.and(owner_id.eq(id)) if id.present?

      where(owner_query)
    end

    def self.owned_by_people
      owned_by('Person')
    end

    def self.owned_by_planners
      owner_type = arel_table[:owner_type]
      owner_query = owner_type.eq('User').or(
        owner_type.eq('SupportUser')
      )
      where(owner_query)
    end

    # Define instance methods
    def deleted?
      deleted_at.present?
    end

    def delete(deleted_by:)
      mark_deleted(deleted_by)
      save
    end

    def delete!(deleted_by:)
      mark_deleted(deleted_by)
      save!
    end

    # If the comment is deleted, ensure that the contents are not shown when
    # the response is rendered
    def body
      if deleted?
        I18n.t('planner.babel.comments.messages.deleted-body')
      else
        self[:body]
      end
    end

    def title
      if deleted? && self[:title].present?
        I18n.t('planner.babel.comments.messages.deleted-title')
      else
        self[:title]
      end
    end

    protected

    def mark_deleted(deleted_by)
      return I18n.t('planner.babel.comments.errors.no-deletion-actor-specified') unless deleted_by.present?
      self.deleted_at = DateTime.current
      self.deleted_by = deleted_by
    end
  end
end
