require 'rails_helper'

describe AnnuaireHelper do
  describe 'attribute_diff_span' do
    subject { helper.attribute_diff_span(*params) }

    context 'new attribute' do
      let(:params) { [User, '+', :phone_number, '0123456789'] }

      it{ is_expected.to eq '<span class="attribute-diff" data-type="+"><label>Téléphone</label><span>0123456789</span></span>' }
    end

    context 'existing attribute' do
      let(:params) { [User, '~', :full_name, 'Colonel Moutarde', 'Général Moutarde'] }

      it{ is_expected.to eq '<span class="attribute-diff" data-type="~"><label>Prénom et nom</label><span>Colonel Moutarde</span><span>Général Moutarde</span></span>' }
    end

    context 'removed attribute' do
      let(:params) { [User, '-', :job, 'Apprenti'] }

      it{ is_expected.to eq '<span class="attribute-diff" data-type="-"><label>Fonction</label><span>Apprenti</span></span>' }
    end
  end
end
