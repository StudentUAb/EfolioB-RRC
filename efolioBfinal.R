#============================================================================
# UC: 21097 - Raciocínio e Representação do Conhecimento - 02 - UAb
# e-fólio B  2023-24 
#
# Aluno: 2100927 - Ivo Baptista
# Name        : efolioB.R
# Author      : Ivo Baptista
# Version     : 1.7
# Copyright   : Ivo copyright 
# Description : Taxa de jovens não empregados que não estão em educação ou formação
# ===========================================================================
# Definir o diretório de trabalho
setwd("~/Desktop/UAb_Disciplinas/21097 - Raciocínio e Representação do Conhecimento/EfolioB/programaR")

# Instalar pacotes necessários se não estiverem instalados
if (!require('randomForest')) install.packages('randomForest', dependencies=TRUE)
if (!require('caret')) install.packages('caret', dependencies=TRUE)
if (!require('nnet')) install.packages('nnet', dependencies=TRUE)
if (!require('ggplot2')) install.packages('ggplot2', dependencies=TRUE)

# Carregar bibliotecas
library(randomForest)
library(caret)
library(nnet)
library(ggplot2)

# Carregar os dados
dados <- read.csv("dados_jovens.csv", header = TRUE, sep = ";", stringsAsFactors = FALSE, fill = TRUE)

# Visualizar os dados para verificar se foram carregados corretamente
head(dados)

# Verificar a estrutura dos dados
str(dados)

# Converter variáveis de caracteres para numéricos (necessário para processamento correto)
dados$X1 <- as.numeric(sub(",", ".", dados$X1))
dados$X2 <- as.numeric(sub(",", ".", dados$X2))
dados$X3 <- as.numeric(sub(",", ".", dados$X3))
dados$X4 <- as.numeric(sub(",", ".", dados$X4))

# Remover linhas com valores NA
dados <- na.omit(dados)

# Adicionar coluna Meta_Atingida: 1 para sim e 2 para não
dados$Meta_Atingida <- ifelse(dados$X1 <= 9, 1, 2)

# Visualizar os dados
head(dados)

# Separar variáveis independentes e dependente
variaveis_independentes <- dados[, c("X2", "X3", "X4")]
variavel_dependente <- dados$Meta_Atingida

# Garantir que a variável dependente é um fator
variavel_dependente <- as.factor(variavel_dependente)

# Combinar variáveis independentes e dependente novamente para formar os conjuntos de treino e teste
dados_completo <- cbind(variaveis_independentes, Meta_Atingida = variavel_dependente)

# Divisão em conjuntos de treino e teste
set.seed(123)
indices <- sample(1:nrow(dados_completo), size = 0.7 * nrow(dados_completo))
treino <- dados_completo[indices, ]
teste <- dados_completo[-indices, ]

### 4.1. Tarefa 4.1: Árvores de Decisão

# Treinar o modelo de árvore de decisão
arvore_modelo <- randomForest(x = treino[, 1:3], y = treino[, 4], ntree = 100, importance = TRUE)
print(arvore_modelo)

# Confirmar que foi uma classificação e não uma regressão
print(arvore_modelo$type)

# Fazer previsões no conjunto de teste
pred_arvore <- predict(arvore_modelo, teste[, 1:3])

# Avaliar a performance do modelo
cat("Árvore de Decisão - Matriz de Confusão:\n")
conf_mat_arvore <- confusionMatrix(pred_arvore, teste[, 4])
print(conf_mat_arvore)

# Importância das Variáveis na Árvore de Decisão
cat("Importância das Variáveis:\n")
print(importance(arvore_modelo))
varImpPlot(arvore_modelo)

### 4.2. Tarefa 4.2: K Vizinhos Mais Próximos

# Treinar o modelo de KNN
knn_modelo <- knn3(x = treino[, 1:3], y = treino[, 4], k = 3)
print(knn_modelo)

# Fazer previsões no conjunto de teste
pred_knn <- predict(knn_modelo, teste[, 1:3])

# Ajustar níveis para a matriz de confusão
pred_knn <- factor(max.col(pred_knn), levels = levels(teste$Meta_Atingida))

# Avaliar a performance do modelo
cat("K Vizinhos Mais Próximos - Matriz de Confusão:\n")
conf_mat_knn <- confusionMatrix(pred_knn, teste$Meta_Atingida)
print(conf_mat_knn)

### 4.3. Tarefa 4.3: Redes Neuronais

# Treinar o modelo de rede neural
rede_modelo <- nnet(Meta_Atingida ~ ., data = treino, size = 5, linout = FALSE, maxit = 200, trace = FALSE)
print(rede_modelo)

# Mostrar os pesos da rede
cat("Pesos da Rede Neuronal:\n")
print(rede_modelo$wts)

# Fazer previsões no conjunto de teste
pred_rede <- predict(rede_modelo, teste[, 1:3], type = "class")

# Ajustar níveis para a matriz de confusão
pred_rede <- factor(pred_rede, levels = levels(teste$Meta_Atingida))

# Avaliar a performance do modelo
cat("Redes Neurais - Matriz de Confusão:\n")
conf_mat_rede <- confusionMatrix(pred_rede, teste$Meta_Atingida)
print(conf_mat_rede)

### Resultados e Reflexões

# Árvore de Decisão - Resultados
cat("\nResultados - Árvore de Decisão:\n")
cat("Erro Médio Estimado: ", mean(arvore_modelo$err.rate[,1]), "\n")
cat("Importância das Variáveis:\n")
print(importance(arvore_modelo))
print(conf_mat_arvore)

# K Vizinhos Mais Próximos - Resultados
cat("\nResultados - K Vizinhos Mais Próximos:\n")
print(conf_mat_knn)

# Redes Neurais - Resultados
cat("\nResultados - Redes Neurais:\n")
print(conf_mat_rede)

### Conclusão
cat("\nConclusão:\n")
cat("Após aplicar os três métodos de aprendizagem supervisionada, foram observados os seguintes resultados:\n")
cat("Árvore de Decisão apresentou um erro médio estimado de ", mean(arvore_modelo$err.rate[,1]), " e mostrou que a variável mais importante foi X2.\n")
cat("O método K Vizinhos Mais Próximos teve uma precisão de ", conf_mat_knn$overall['Accuracy'], ".\n")
cat("O método de Redes Neurais teve uma precisão de ", conf_mat_rede$overall['Accuracy'], ".\n")
cat("Analisando os resultados, podemos concluir que o modelo de Árvores de Decisão apresentou melhor performance em termos de erro médio, enquanto o modelo de Redes Neurais teve uma precisão ligeiramente inferior. O K Vizinhos Mais Próximos teve a menor precisão entre os três métodos.\n")
