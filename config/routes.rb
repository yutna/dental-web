Rails.application.routes.draw do
  locale = /en|th/
  invalid_locale = /(?!en|th)[a-z]{2}/

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "/", to: redirect("/#{I18n.default_locale}", status: 302), as: nil

  scope ":locale", locale: locale do
    root "home#index"
    resource :session, only: %i[new create destroy], module: :auth
    resource :workspace, only: :show, controller: "workspace"

    namespace :dental do
      root "home#show"
      get "visits/:id", to: "visits#show", as: :visit
      patch "visits/:id/transition", to: "visits#transition", as: :visit_transition
    end

    namespace :admin do
      root "dashboard#show"
      resources :clinic_services, except: :show

      namespace :dental do
        root "dashboard#show"

        namespace :master_data do
          resources :procedure_items, except: :show do
            collection do
              post :bulk_import_preview
              post :bulk_import_apply
            end
          end
        end
      end
    end
  end

  get "/:locale", to: redirect("/#{I18n.default_locale}", status: 302), constraints: { locale: invalid_locale }, as: nil
  get "/:locale/*path", to: redirect("/#{I18n.default_locale}/%{path}", status: 302), constraints: { locale: invalid_locale }, format: false, as: nil
end
