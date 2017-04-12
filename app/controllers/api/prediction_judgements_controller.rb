module Api
  class PredictionJudgementsController < AuthorisedController
    def create
      @prediction = Prediction.find(params[:prediction_id])
      raise UnauthorizedRequest unless @user.authorized_for(@groups, @prediction)
      @prediction.judge!(params[:outcome], @user)
      render status: :created, json: @prediction.judgements.last
    end
  end
end
