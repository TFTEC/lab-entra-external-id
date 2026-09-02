// Uso opcional do instrutor: cria um tenant externo do Microsoft Entra External ID vinculado à assinatura.
// Os alunos criam o tenant pelo portal (docs/00). Implante em um resource group SÓ para o tenant
// (ex.: rg-lab-externalid-tenant); nunca no grupo do App Service, que é esvaziado pelo deprovision.yml.
// Quem executa a implantação (usuário interativo) vira administrador do tenant. Pode levar até 30 minutos.
targetScope = 'resourceGroup'

@description('Subdomínio do tenant: vira <nome>.onmicrosoft.com e <nome>.ciamlogin.com. Só letras minúsculas e números.')
@minLength(1)
@maxLength(26)
param subdominio string

@description('Nome de exibição do tenant.')
param displayName string = 'Lab External ID - TFTEC'

@description('País/região do tenant (imutável). A API ARM recusou BR em 2026-09-02; use US (o portal aceita Brasil).')
param countryCode string = 'US'

@description('Localização dos dados. Valores aceitos pelo ARM: United States, Europe, Asia Pacific, Australia.')
@allowed([
  'United States'
  'Europe'
  'Asia Pacific'
  'Australia'
])
param dataLocation string = 'United States'

resource tenant 'Microsoft.AzureActiveDirectory/ciamDirectories@2023-05-17-preview' = {
  #disable-next-line BCP335
  name: '${subdominio}.onmicrosoft.com' // o sufixo é obrigatório; o aviso de tamanho do Bicep pode ser ignorado
  location: dataLocation
  sku: {
    name: 'Base' // único SKU aceito pelo provider (preflight recusa 'Standard')
    tier: 'A0'
  }
  properties: {
    createTenantProperties: {
      displayName: displayName
      countryCode: countryCode
    }
  }
}

output tenantId string = tenant.properties.tenantId
output dominio string = '${subdominio}.onmicrosoft.com'
output authority string = 'https://${subdominio}.ciamlogin.com/'
