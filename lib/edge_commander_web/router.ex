defmodule EdgeCommanderWeb.Router do
  use EdgeCommanderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :swagger_auth do
    plug EdgeCommanderWeb.AuthenticationPlug
  end

  pipeline :auth do
    plug EdgeCommander.Accounts.Pipeline
  end
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Edge Commander"
      },
      host: "app.edgecommander.com",
      tags: [
        %{
          name: "sims",
          description: "Everything about sims"
        },
        %{
          name: "nvrs",
          description: "Operations related to nvrs"
        },
        %{
          name: "sites",
          description: "Operations related to sites"
        },
        %{
          name: "rules",
          description: "Operations related to rules"
        },
        %{
          name: "routers",
          description: "Operations related to routers"
        }
      ]
    }
  end

  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :edge_commander,
      swagger_file: "swagger.json",
      disable_validator: true
  end

  # Maybe logged in scope
  scope "/", EdgeCommanderWeb do
    pipe_through [:browser, :auth]
    
    get "/", DashboardController, :sign_in
    post "/users/session", SessionController, :create
    get "/users/session", SessionController, :delete
    post "/users/sign_up", UsersController, :sign_up
    get "/users/forgot_password", DashboardController, :forgot_password
    get "/users/reset_password/:token", DashboardController, :reset_password
    post "/users/forgot_password", UsersController, :forgot_password
    post "/users/reset_password", UsersController, :reset_password
    get "/receive_sms", SimsController, :receive_sms
    get "/delivery_receipt", SimsController, :delivery_receipt
    get "/users/reset_password_success", DashboardController, :reset_password_success
  end

  scope "/", EdgeCommanderWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/get_porfile", UsersController, :get_porfile
    get "/about", RooterController, :main
    get "/sims", RooterController, :main
    get "/nvrs", RooterController, :main
    get "/routers", RooterController, :main
    get "/commands", RooterController, :main
    get "/sims/:sim_number", RooterController, :main
    get "/sites", RooterController, :main
    get "/messages", RooterController, :main
    get "/status_report", RooterController, :main
    get "/api", RooterController, :main
    get "/shares", RooterController, :main
    get "/dashboard", RooterController, :main
    get "/battery/:id", RooterController, :main
    get "/batteries", RooterController, :main
    get "/my_profile", RooterController, :main
    get "/three_users", RooterController, :main
    get "/activities", RooterController, :main
    get "/sharing", RooterController, :main

    get "/sims/data/json", SimsController, :get_sim_logs
    get "/sims/data/:sim_number", SimsController, :get_single_sim_data
    get "/chartjs/data/:sim_number", SimsController, :create_chartjs_line_data
    get "/sims/sms/:sim_number", SimsController, :get_single_sim_sms
    post "/sims", SimsController, :create
    post "/messages", SimsController, :create
    get "/user_logs", LogsController, :get_user_logs
    get "/sims/name/:sim_number", SimsController, :get_single_sim_name
    patch "/sim/:id", SimsController, :update
    get "/all_sim", SimsController, :get_all_sims
    delete "/sims/:id", SimsController, :delete_sim

    get "/routers/data", RoutersController, :get_all_routers
    post "/routers", RoutersController, :create
    patch "/routers/:id", RoutersController, :update
    delete "/routers/:id", RoutersController, :delete_router
    get "/all_routers", RoutersController, :get_all

    get "/nvrs/data", NvrsController, :get_all_nvrs
    post "/nvrs", NvrsController, :create
    delete "/nvrs/:id", NvrsController, :delete_nvr
    patch "/nvrs/:id", NvrsController, :update
    get "/nvrs/:id", NvrsController, :reboot
    get "/all_nvrs", NvrsController, :get_all

    get "/members", SharingController, :get_all_members
    post "/members/new", SharingController, :create
    delete "/members/:id", SharingController, :delete

    get "/rules", CommandsController, :get_all_rules
    post "/rules/new", CommandsController, :create
    patch "/rules/update", CommandsController, :update
    delete "/rules/:id", CommandsController, :delete_rule

    get "/sites/data", SitesController, :get_all_sites
    post "/sites/new", SitesController, :create
    patch "/sites/update", SitesController, :update
    delete "/sites/:id", SitesController, :delete_site

    get "/update_status_report", NvrsController, :update_status_report

    patch "/update_profile", UsersController, :update_profile

    post "/send_sms", SimsController, :send_sms
    get "/get_all_sms", SmsController, :get_all_sms
    get "/daily_sms_count/:number", SimsController, :daily_sms_count

    get "/three_accounts", ThreeController, :get_all_three_accounts
    post "/three_accounts", ThreeController, :create
    patch "/three_accounts", ThreeController, :update
    delete "/three_accounts/:id", ThreeController, :delete

    get "/dashboard/total_sims", DashboardController, :total_sims
    get "/dashboard/total_nvrs", DashboardController, :total_nvrs
    get "/dashboard/total_routers", DashboardController, :total_routers
    get "/dashboard/total_sites", DashboardController, :total_sites
    get "/dashboard/weekly_sms_overview", DashboardController, :weekly_sms_overview

    get "/batteries/reading", BatteryReadingController, :get_battery_record
    get "/daily_battery/data/:battery_id/:from_date/:to_date", DashboardController, :daily_batery_voltages
    get "/battery_voltages_summary/data/:battery_id/:from_date/:to_date", DashboardController, :battery_voltages_summary

    get "/battery", BatteryController, :get_all_batteries
    post "/battery/new", BatteryController, :create
    patch "/battery/update", BatteryController, :update
    delete "/battery/:id", BatteryController, :delete_battery
    get "/battery/data/:battery_id", BatteryController, :get_single_battery

  end

  # Other scopes may use custom stacks.
  scope "/v1", EdgeCommanderWeb do
    pipe_through :api

    scope "/" do
      pipe_through :swagger_auth

      get "/sims", SimsController, :get_sim_logs
      get "/sims/:sim_number/usage", SimsController, :create_chartjs_line_data
      get "/sims/:sim_number", SimsController, :get_single_sim_data
      get "/sims/:sim_number/sms", SimsController, :get_single_sim_sms
      post "/sims", SimsController, :create

      get "/routers", RoutersController, :get_all_routers
      post "/routers", RoutersController, :create
      patch "/routers/:id", RoutersController, :update
      delete "/routers/:id", RoutersController, :delete

      get "/nvrs", NvrsController, :get_all_nvrs
      post "/nvrs", NvrsController, :create
      delete "/nvrs/:id", NvrsController, :delete
      patch "/nvrs/:id", NvrsController, :update

      get "/rules", CommandsController, :get_all_rules
      post "/rules/new", CommandsController, :create
      patch "/rules/update", CommandsController, :update
      delete "/rules/:id", CommandsController, :delete

      get "/sites", SitesController, :get_all_sites
      post "/sites/new", SitesController, :create
      patch "/sites/update", SitesController, :update
      delete "/sites/:id", SitesController, :delete

      patch "/update_profile", UsersController, :update_profile

      post "/sims/:sim_number/sms", SimsController, :send_sms
      get "/receive_sms", SimsController, :receive_sms
      get "/delivery_receipt", SimsController, :delivery_receipt
      get "/daily_sms_count/:number", SimsController, :daily_sms_count

      get "/get_all_sms/:from_date/:to_date", SmsController, :get_all_sms
    end
  end
end
