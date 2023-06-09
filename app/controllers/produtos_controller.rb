class ProdutosController < ApplicationController

  before_action :set_produto, only: [:show]
  def index
    @produto = Produto.all
  end

  def new
    @produto = Produto.new
  end

  def create
    valores = params.require(:produto).permit(:nome, :descricao, :preco, :quantidade, :imagem, :marca, :content)
    @produto = Produto.new valores
    if @produto.save
      flash[:notice] = "produto salvo com sucesso"
      render :new
    else
      flash[:error] = "produto não foi salvo"
      render :new
      end
  end



  def destroy
    remove_id = params[:id]
    Produto.destroy remove_id
    redirect_to produtos_path
  end

  def busca
    @nome = params[:nome]
    @produto = Produto.where "nome like ?", "%#{@nome}%"


  end

  def show
    @produto = Produto.find(params[:id])
  end

  def set_produto
    @produto = Produto.find (params[:id])
  end

  def home
    @produto = Produto.all
  end

  def adicionar_ao_carrinho
    @produto = Produto.find(params[:produto_id])
    current_user.produtos_carrinho << @produto # Altere para a relação correta entre usuários e produtos no seu modelo
    redirect_to carrinho_path, notice: 'Produto adicionado ao carrinho com sucesso.'
  end

end
