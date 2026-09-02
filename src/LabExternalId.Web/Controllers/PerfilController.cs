using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace LabExternalId.Web.Controllers;

/// <summary>Única área protegida do app: acessar /Perfil sem sessão dispara o login no Entra External ID.</summary>
[Authorize]
public class PerfilController : Controller
{
    public IActionResult Index() => View();
}
