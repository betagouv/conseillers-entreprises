class MakeContactEmailGloballyUnique < ActiveRecord::Migration[8.1]
  def up
    merge_duplicate_contacts_by_email

    remove_reference :contacts, :company, foreign_key: true, index: true

    remove_index :contacts, :email
    add_index :contacts, :email, unique: true, where: "email IS NOT NULL AND email != ''"
  end

  def down
    remove_index :contacts, :email
    add_index :contacts, :email

    add_reference :contacts, :company, foreign_key: true
  end

  private

  def merge_duplicate_contacts_by_email
    duplicate_emails = Contact.where.not(email: [nil, '']).group('lower(email)').having('COUNT(*) > 1').pluck('lower(email)')

    duplicate_emails.each do |email|
      survivor, *duplicates = Contact.where('lower(email) = ?', email).order(created_at: :desc, id: :desc).to_a
      phone_number = survivor.phone_number.presence || duplicates.find { |contact| contact.phone_number.present? }&.phone_number
      survivor.update_columns(email: email, phone_number: phone_number)

      Diagnosis.where(visitee_id: duplicates.map(&:id)).update_all(visitee_id: survivor.id)
      Contact.where(id: duplicates.map(&:id)).delete_all
    end
  end
end
