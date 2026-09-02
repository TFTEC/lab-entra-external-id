namespace LabExternalId.Web.Models;

/// <summary>Indica qual fluxo OpenID Connect o app está usando, decidido na inicialização pela configuração.</summary>
public sealed record ModoAutenticacao(bool UsaClientSecret)
{
    public string Descricao => UsaClientSecret
        ? "Authorization code + PKCE (com client secret)"
        : "ID token (fluxo implícito, sem client secret)";
}
