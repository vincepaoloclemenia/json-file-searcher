class ClientsController < ApplicationController
  def index
    render json: [] and return if params[:query].blank?
    render json: JsonSearcherService.new(query: filtered_params.slice(:full_name, :email), find_duplicates:).call
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def filtered_params
    raise StandardError, 'Query must have keys' unless params[:query].respond_to?(:to_h)
    raise StandardError, "Missing query keys: (full_name, email)" unless query_params.any? { |k, _v| JsonSearcherService::VALID_QUERY_ATTRIBUTES.include?(k.to_sym) }

    query_params
  end

  def find_duplicates
    return false if params[:find_duplicates].blank?

    case params[:find_duplicates]
    when 1, '1', 'true'
      true
    else
      false
    end
  end

  def query_params
    params.require(:query).permit(*JsonSearcherService::VALID_QUERY_ATTRIBUTES).to_h
  end
end