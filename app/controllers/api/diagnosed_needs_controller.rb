# frozen_string_literal: true

module Api
  class DiagnosedNeedsController < ApplicationController
    def index
      # @contacts = Contact.joins(:visits).where(visits: { id: params[:visit_id] })
      @diagnosed_needs = DiagnosedNeed.joins(:diagnoses).where(diagnoses: { id: params[:diagnosis_id] })
    end

    def bulk
      DiagnosedNeed.transaction do
        DiagnosedNeed.create bulk_create_param_array
        DiagnosedNeed.update(bulk_update_param_hash.keys, bulk_update_param_hash.values)
        DiagnosedNeed.destroy bulk_delete_param_array
      end

      render body: nil
    rescue StandardError
      render body: nil, status: :bad_request
    end

    private

    def bulk_create_param_array
      create_param = params.require(:bulk_params).permit(create: %i[question_id question_label content])
      create_param.fetch(:create, []).map { |need_params| need_params.merge!(diagnosis_id: params[:diagnosis_id]) }
    end

    def bulk_update_param_hash
      update_param = params.require(:bulk_params).permit(update: %i[id content])
      update_param.fetch(:update, [])
                  .delete_if { |update_item| update_item[:id].nil? }
                  .group_by { |update_item| update_item[:id] }
                  .each_with_object({}) { |(k, v), hash| hash[k] = { content: v.first&.fetch('content', '') } }
    end

    def bulk_delete_param_array
      delete_param = params.require(:bulk_params).permit(delete: %i[id])
      delete_param.fetch(:delete, []).map(&:values).map(&:first)
    end
  end
end
