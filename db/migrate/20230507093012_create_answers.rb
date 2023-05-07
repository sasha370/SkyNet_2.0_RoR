class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.string :chat_id, null: false
      t.string :text
      t.text :reply_markup
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
