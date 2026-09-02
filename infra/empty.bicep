// Template vazio. Implantado em modo Complete, remove todos os recursos do resource group
// e preserva o próprio grupo e as atribuições de papel (usado por .github/workflows/deprovision.yml).
targetScope = 'resourceGroup'

output resourceGroupName string = resourceGroup().name
