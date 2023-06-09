class UsersController < ApplicationController

  helper_method :current_user


  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  def login
    if current_user
      flash.now[:notice] = "You are already logged in."
    end
  end


  def authenticate
    email = params[:email].downcase # Converter o e-mail para letras minúsculas

    user = User.find_by(email: email)

    if user
      user.update(logged_in: true)
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email"
      render :login
    end
  end




  def user_index
    @user = User.all
  end

  def register
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # Redirecionar para a página de sucesso ou fazer outras ações necessárias
      redirect_to root_path, notice: "User created successfully"
    else
      # Caso haja erros de validação, renderizar novamente o formulário com as mensagens de erro
      render :register
    end
  end

  def add_to_wallet
    @user = User.find(params[:id])
    amount = params[:amount].gsub(',', '.').to_f

    if amount.positive?
      @user.add_to_wallet(amount)
      redirect_to user_path(@user), notice: 'Amount added to wallet successfully'
    else
      redirect_to user_path(@user), alert: 'Invalid amount'
    end
  end


  def deduct_from_wallet
    @user = User.find(params[:id])
    amount = params[:amount].to_f

    if amount.positive? && @user.wallet_balance >= amount
      @user.deduct_from_wallet(amount)
      @user.produtos.clear # Remove todos os produtos do carrinho
      redirect_to carrinho_path
    else
      redirect_to carrinho_path
    end
  end

  def carteira
    @user = current_user

  end

  def destroy
    remove_id = params[:id]
    User.destroy remove_id
    redirect_to user_index_path
  end

  def add_to_cart
    @user = current_user
    @produto = Produto.find(params[:produto_id])

    # Verifique se o produto já está no carrinho do usuário
    if @user.produtos.include?(@produto)
      flash[:alert] = 'O produto já está no carrinho'
    else
      # Adicione o produto ao carrinho do usuário
      @user.produtos << @produto
      flash[:notice] = 'Produto adicionado ao carrinho com sucesso'
    end

    redirect_to carrinho_path
  end

  def carrinho
    @user = current_user
    @produtos = @user.produtos
  end

  def remover_do_carrinho
    @user = current_user
    @produto = Produto.find(params[:produto_id])

    # Remova o produto do carrinho do usuário
    @user.produtos.delete(@produto)

    flash[:notice] = 'Produto removido do carrinho com sucesso'
    redirect_to carrinho_path
  end


  private

  def user_params
    params.require(:user).permit(:name, :email)
  end



end
