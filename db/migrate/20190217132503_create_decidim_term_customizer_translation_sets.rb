# frozen_string_literal: true

class CreateDecidimTermCustomizerTranslationSets < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_term_customizer_translation_sets do |t|
      t.jsonb :name
    end
  end
end
