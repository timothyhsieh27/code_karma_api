#
module DeveloperProjectsHelper
  def set_current_user
    @user = @current_user
  end

  def authorized_developer?
    @developer_project.developer == @current_user.account
  end

  def show_dev_projects
    @developer_projects = DeveloperProject.where(developer_id: @current_user.account.id)
    render json: @developer_projects
  end

  def new_dev_project
    @developer_project = DeveloperProject.new developer_project_params
    @developer_project.developer_id = @current_user.account.id
  end

  def save_dev_project
    @developer_project.save
    render json: @developer_project
  end

  def edit_dev_project
    @developer_project.update developer_project_params
    render json: @developer_project
  end

  def delete_dev_project
    @developer_project.destroy
    render json: {}, status: :ok
  end

  def find_dev_project_by_id
    @developer_project = DeveloperProject.find params[:id]
  end

  def get_github_project_branches
    find_dev_project_by_id
    calculate_branch_request_url
    branch_request_github
  end

  def calculate_branch_request_url
    url = @developer_project.project_id.github_repo_url
    owner_repo_array = url.scan(/https\:\/\/github\.com\/(\w*)\/(\w*)/).first
    owner = owner_repo_array[0]
    repo = owner_repo_array[1]
    @branch_github_api_url = "https://api.github.com/#{owner}/#{repo}/branches"
  end

  def branch_request_github
    HTTParty.get(@branch_github_api_url,
      :headers => { 'Authorization' => "token #{@user.github_token}",
                    'Content-Type' => 'application/json',
                    'User-Agent' => 'Code-Karma-API' }
    )
  end

  def post_pull_request
    find_dev_project_by_id
    set_current_user
    if is_developer?
      url = @developer_project.project.github_repo_url
      owner_repo_array = url.scan(/https\:\/\/github\.com\/(\w*)\/(\w*)/).first
      owner = owner_repo_array[0]
      repo = owner_repo_array[1]
      # pull_github_api = "https://api.github.com/repos/#{owner}/#{repo}/pulls"
      pull_github_api = "https://api.github.com/repos/kteich88/Practice-Rspec/pulls"
      pull_title = "Kristine you should totally accept this Amazing Pull Request."
      head_branch = "master"
      base_branch = "new_test"
      pull_body = "Like seriously plz accept it."
      e = HTTParty.post(pull_github_api,
      :headers => { 'Authorization' => "token #{@user.github_token}",
                    'Content-Type' => 'application/json',
                    'User-Agent' => 'Code-Karma-API'},

      :query =>    { 'title' => "#{pull_title}",
                    'base' => "#{base_branch}",
                    'head' => "#{head_branch}",
                    'body' => "#{pull_body}"}
      )
      binding.pry
    else
      wrong_syntax_error
    end
  end

  def wrong_user_error
    render json: { error: 'Incorrect User' }, status: 403
  end

  def wrong_syntax_error
    render json: { errors: 'Semantically Erroneous Instructions' }, status: 422
  end
end
