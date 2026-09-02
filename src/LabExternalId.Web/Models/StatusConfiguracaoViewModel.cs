namespace LabExternalId.Web.Models;

public sealed class StatusConfiguracaoViewModel
{
    public required string Authority { get; init; }
    public required string ClientId { get; init; }
    public required ModoAutenticacao Modo { get; init; }
    public required bool ConfiguracaoPendente { get; init; }
}
