using System.IdentityModel.Tokens.Jwt;
using LabExternalId.Web.Models;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;

// Mantém os nomes originais das claims (oid, sub, preferred_username) em vez dos URIs longos do SAML.
// Precisa ser a primeira instrução, antes de qualquer opção de autenticação ser construída.
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;

var builder = WebApplication.CreateBuilder(args);

// Seção "AzureAd" do appsettings.json (ou variáveis de ambiente AzureAd__Chave no App Service).
var azureAd = builder.Configuration.GetSection("AzureAd");

// Com segredo configurado -> authorization code + PKCE (o app troca o código por tokens no servidor).
// Sem segredo            -> fluxo implícito de ID token (exige "ID tokens" marcado no app registration).
var usaClientSecret = !string.IsNullOrWhiteSpace(azureAd["ClientSecret"])
                      || azureAd.GetSection("ClientCredentials").Exists();

var autenticacao = builder.Services
    .AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(azureAd);

if (usaClientSecret)
{
    autenticacao
        .EnableTokenAcquisitionToCallDownstreamApi()
        .AddInMemoryTokenCaches();
}

builder.Services.AddSingleton(new ModoAutenticacao(usaClientSecret));

// Sem filtro global de autorização: a página inicial é pública; só /Perfil exige login.
builder.Services.AddControllersWithViews();

// AddMicrosoftIdentityUI registra as rotas /MicrosoftIdentity/Account/SignIn e /SignOut.
// AddRazorPages é necessário porque a página "SignedOut" do pacote é uma Razor Page.
builder.Services.AddRazorPages().AddMicrosoftIdentityUI();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.MapRazorPages().WithStaticAssets();

app.Run();
