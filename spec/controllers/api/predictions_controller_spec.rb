# frozen_string_literal: true

require 'spec_helper'

describe Api::PredictionsController, type: :controller do
  let(:user) { FactoryBot.create(:user, api_token: 'real-token') }
  let(:prediction) { FactoryBot.create(:prediction) }

  before do
    user
    prediction
  end

  describe 'GET /predictions' do
    context 'with valid API token' do
      before do
        get :index, params: { api_token: user.api_token }
      end

      specify { expect(response).to be_success }
      specify { expect(response.content_type).to eq 'application/json' }
      specify { expect(response.body).to include prediction.description_with_group }
    end

    context 'with invalid API token' do
      before { get :index, params: { api_token: 'fake-token' } }

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq 'application/json' }
    end
  end

  describe 'GET /predictions/:id' do
    context 'with valid API token' do
      before do
        get :show, params: { id: prediction.id, api_token: user.api_token }
      end

      specify { expect(response).to be_success }
      specify { expect(response.content_type).to eq 'application/json' }
      specify { expect(response.body).to_not be_empty }
    end

    context 'with invalid API token' do
      before { get :show, params: { id: prediction.id, api_token: 'fake-token' } }

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq 'application/json' }
    end

    context 'with non-existent id' do
      before { get :show, params: { id: 999, api_token: 'fake-token' } }

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq 'application/json' }
    end
  end

  describe 'POST /predictions' do
    let(:prediction_params) do
      {
        description: 'The world will end tomorrow!',
        deadline: 1.day.ago,
        initial_confidence: '100'
      }
    end

    context 'with valid API token' do
      it 'creates a new prediction' do
        post :create, params: { prediction: prediction_params, api_token: user.api_token }
        expect(response.body).to include(prediction_params[:description])
      end

      context 'with a malformed prediction' do
        before do
          prediction_params[:initial_confidence] = 9000
          post :create, params: { prediction: prediction_params, api_token: user.api_token }
        end

        specify { expect(response).to_not be_success }
        specify { expect(response.body).to include('a probability is between') }
      end

      context 'with new visibility' do
        let(:prediction_params) do
          {
            description: 'The world will end tomorrow!',
            deadline: 1.day.ago,
            initial_confidence: '100',
            visibility: 'visible_to_creator'
          }
        end

        before { post :create, params: { prediction: prediction_params, api_token: user.api_token } }

        specify do
          expect(Prediction.last.visible_to_creator?).to be true
        end
      end

      context 'with old private flag' do
        let(:prediction_params) do
          {
            description: 'The world will end tomorrow!',
            deadline: 1.day.ago,
            initial_confidence: '100',
            private: true
          }
        end

        before { post :create, params: { prediction: prediction_params, api_token: user.api_token } }

        specify do
          expect(Prediction.last.visible_to_creator?).to be true
        end
      end
    end

    context 'with invalid API token' do
      before do
        post :create, params: { api_token: 'fake-token', prediction: prediction_params }
      end

      specify do
        expect(response.body).to_not include(prediction_params[:description])
      end

      specify { expect(response).to_not be_success }
    end
  end

  describe 'PUT /predictions/:id' do
    let(:new_prediction_params) do
      { description: 'The world definitely will not end tomorrow!' }
    end
    let(:prediction) { FactoryBot.create(:prediction, creator: user) }

    context 'with valid API token' do
      context 'authorized user' do
        before do
          put :update, params: { api_token: user.api_token,
                                 id: prediction.id,
                                 prediction: new_prediction_params }
        end

        specify { expect(response).to be_success }
        specify { expect(response.content_type).to eq 'application/json' }

        it 'updates the existing prediction' do
          description = new_prediction_params[:description]
          prediction.reload

          expect(prediction.description_with_group).to eq(description)
        end
      end

      context 'unauthorized user' do
        before do
          put :update, params: { api_token: 'fake-token',
                                 id: prediction.id,
                                 prediction: new_prediction_params }
        end

        specify { expect(response).to_not be_success }
        specify { expect(response.content_type).to eq 'application/json' }
      end
    end

    context 'with invalid API token' do
      before do
        put :update, params: { api_token: 'fake-token',
                               id: prediction.id,
                               prediction: new_prediction_params }
      end

      specify { expect(response).to_not be_success }
      specify { expect(response.content_type).to eq 'application/json' }
    end
  end
end
