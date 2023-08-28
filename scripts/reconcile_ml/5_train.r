### TRAIN ###


source("3_hyperparameters.R")

# treino
model = learners$lm$train(task)

# salvar
saveRDS(model, "data/model.RDS", compress = FALSE)