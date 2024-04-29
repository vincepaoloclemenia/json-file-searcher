class ClientsController < ApplicationController
  def index
    render json: JsonSearcherService.new(query: filtered_params.to_h.slice(:full_name, :email), find_duplicates: true).call
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def filtered_params
    params.permit(:full_name, :email, :find_duplicates)
  end
end