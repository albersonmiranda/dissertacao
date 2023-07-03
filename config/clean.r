# POST RENDER CLEAN-UP #


# copiar arquivos para render
para_copia = list.files(pattern = ".pdf")

if (file.exists(para_copia)) {
  # copiar arquivos para render
  file.copy(para_copia, "render", overwrite = TRUE)
}

# remover arquivos da raiz
para_deletar = list.files(pattern = ".loq")
if (file.exists(para_copia)) {
  file.remove(para_copia)
  file.remove(para_deletar)
}
