using System.Diagnostics;
using LabExternalId.Web.Models;
using Microsoft.AspNetCore.Mvc;

namespace LabExternalId.Web.Controllers;

public class HomeController(IConfiguration configuracao, ModoAutenticacao modo) : Controller
{
    public IActionResult Index()
    {
        var authority = configuracao["AzureAd:Authority"] ?? string.Empty;
        var clientId = configuracao["AzureAd:ClientId"] ?? string.Empty;

        var pendente = string.IsNullOrWhiteSpace(authority)
                       || string.IsNullOrWhiteSpace(clientId)
                       || authority.Contains("SEU-", StringComparison.OrdinalIgnoreCase)
                       || clientId.Contains("SEU-", StringComparison.OrdinalIgnoreCase);

        return View(new StatusConfiguracaoViewModel
        {
            Authority = authority,
            ClientId = clientId,
            Modo = modo,
            ConfiguracaoPendente = pendente
        });
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
