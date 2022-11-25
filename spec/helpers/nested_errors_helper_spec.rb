require 'rails_helper'

describe NestedErrorsHelper do
  describe 'nested_errors_messages' do
    subject { helper.nested_errors_messages(object) }

    let(:object) do
      user = build :user, experts: [build(:expert, full_name: nil)]
      user.validate(:import) # Note: See User.rb: User.validates_associated, on: :import
      user
    end

    it do
      is_expected.to eq <<~RESULT
        Équipe n'est pas valide
        • Nom de l’équipe doit être rempli(e)
      RESULT
    end
  end
end
