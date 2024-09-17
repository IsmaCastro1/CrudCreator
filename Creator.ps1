$controller = Read-Host "Escribe el nombre para el Controlador"
$controller = $controller.Substring(0,1).ToUpper() + $controller.Substring(1)
Clear-Host

function Show-Menu {
    param (
        [string[]]$options
    )

    $selections = @()
    $selectedIndex = 0

    while ($true) {
        Clear-Host
        Write-Host "Selecciona una o varias opciones (usa la barra espaciadora para seleccionar y Enter para finalizar):"
        for ($i = 0; $i -lt $options.Length; $i++) {
            if ($i -eq $selectedIndex) {
                if ($selections -contains $i) {
                    Write-Host " > [*] $($options[$i])" -ForegroundColor Green
                } else {
                    Write-Host " > [ ] $($options[$i])" -ForegroundColor Yellow
                }
            } else {
                if ($selections -contains $i) {
                    Write-Host "   [*] $($options[$i])" -ForegroundColor Green
                } else {
                    Write-Host "   [ ] $($options[$i])"
                }
            }
        }
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($key.VirtualKeyCode) {
            13 { return $selections | Sort-Object } # Enter key
            38 { # Up arrow
                if ($selectedIndex -gt 0) { $selectedIndex-- }
            }
            40 { # Down arrow
                if ($selectedIndex -lt ($options.Length - 1)) { $selectedIndex++ }
            }
            32 { # Spacebar
                if ($selections -contains $selectedIndex) {
                    $selections = $selections | Where-Object { $_ -ne $selectedIndex }
                } else {
                    $selections += $selectedIndex
                }
            }
        }
    }
}

$options = @(
    "GET",
    "PUT",
    "POST",
    "DELETE"
)


$selectedIndices = Show-Menu -options $options

Clear-Host
 "Se van a crear las siguientes opciones"

Write-Host " --> $controller <--" -ForegroundColor blue 

$selectedOptions = @()
foreach ($index in $selectedIndices) {
    Write-Host $options[$index]
    $selectedOptions += $options[$index]
}

Write-Host "Pulsa cualquier tecla para continuar, en caso contrario ctrl + c" -ForegroundColor yellow
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") > $null

#ClasssNames
$controllerClass = $controller + "Controller" 
$mediatorResponseClass = $controller + "Response" 

$GetCommandClass = "Get" + $controller + "Query"
$GetCommandHandlerClass = "Get" + $controller + "QueryHandler"

$postCommandClass = "Create" + $controller + "Command"
$postCommandHandlerClass = "Create" + $controller + "CommandHandler"

$deleteCommandClass = "Delete" + $controller + "Command"
$deleteCommandHandlerClass = "Delete" + $controller + "CommandHandler"

$putCommandClass = "Update" + $controller + "Command"
$putCommandHandlerClass = "Update" + $controller + "CommandHandler"

#Paths
$currentDirectory = Split-Path -Path (Get-Location) -Leaf
$controllerPath = ".\$currentDirectory.Api\Features\$controller"
$MediatorPath = ".\$currentDirectory.Application\Features\$controller"

#Usings
$GetCommandUsing = ""
$PostCommandUsing = ""
$deleteCommandUsing = ""
$PutCommandUsing = ""

#Endpoints
$getEndpoint = ""
$postEndpoint = ""
$putEndpoint = ""
$deleteEndpoint = ""

#Creating Directory
New-Item -Path $controllerPath -ItemType Directory > $null

if($selectedOptions.Contains("GET") -or $selectedOptions.Contains("POST") -or $selectedOptions.Contains("PUT") -or $selectedOptions.Contains("DELETE"))
{
    New-Item -Path $MediatorPath -ItemType Directory > $null
}

$controllerFilePath = ".\$currentDirectory.Api\Features\$controller\$controllerClass.cs"


if($selectedOptions.Contains("GET") -or $selectedOptions.Contains("POST") -or $selectedOptions.Contains("PUT")) 
{
    #creating response model
    $responseFilePath = ".\$currentDirectory.Application\Features\$controller\$mediatorResponseClass.cs"

    $responseFileData = "namespace $currentDirectory.Application.Features.$controller;

                public class $mediatorResponseClass
                {

                }"

    Set-Content -Path $responseFilePath -Value $responseFileData > $null
}

#Building app
if($selectedOptions.Contains("GET"))
{
    #Adding extra data
    $GetCommandUsing = "using $currentDirectory.Application.Features.$Controller.Get;"
    
    $getEndpoint = "[HttpGet]
     public async Task<IActionResult> Get$Controller(CancellationToken ct)
     {
        $GetCommandClass query = new ();
        return Ok(await _mediator.Send(query, ct));
     }
    "
   
    #GET HANDLER

    $getMediatorPath = ".\$currentDirectory.Application\Features\$controller\Get"
    New-Item -Path $getMediatorPath -ItemType Directory > $null
    $MediatorFilePath = ".\$currentDirectory.Application\Features\$controller\Get\$GetCommandClass.cs"

    $GetData = "using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace $currentDirectory.Application.Features.$controller.Get;

public class $GetCommandClass : IRequest<$mediatorResponseClass>
{
}

internal class $GetCommandHandlerClass : IRequestHandler<$GetCommandClass,$mediatorResponseClass>
{
    public $GetCommandHandlerClass()
    {
    
    }
    
    public async Task<$mediatorResponseClass> Handle($GetCommandClass request, CancellationToken ct)
    {
	    return new $mediatorResponseClass();
    }
}

    "

    Set-Content -Path $MediatorFilePath -Value $GetData > $null
}

if($selectedOptions.Contains("POST"))
{
    #Adding extra data
    $PostCommandUsing = "using $currentDirectory.Application.Features.$Controller.Create;"
    
    $postEndpoint = "[HttpPost]
     public async Task<IActionResult> Create$Controller(CancellationToken ct) 
     {
        $postCommandClass command = new ();
        return Ok(await _mediator.Send(command, ct));
     }
    "
   
    #HANDLER

    $postMediatorPath = ".\$currentDirectory.Application\Features\$controller\Create"
    New-Item -Path $postMediatorPath -ItemType Directory > $null

    $MediatorFilePath = ".\$currentDirectory.Application\Features\$controller\Create\$postCommandClass.cs"

    $Data = "using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace $currentDirectory.Application.Features.$controller.Create;

public class $postCommandClass : IRequest<$mediatorResponseClass>
{
}

internal class $postCommandHandlerClass : IRequestHandler<$postCommandClass,$mediatorResponseClass>
{
    public $postCommandHandlerClass()
    {
    
    }
    
    public async Task<$mediatorResponseClass> Handle($postCommandClass request, CancellationToken ct)
    {
	    return new $mediatorResponseClass();
    }
}

    "

    Set-Content -Path $MediatorFilePath -Value $Data > $null
}

if($selectedOptions.Contains("DELETE"))
{
    #Adding extra data
    $deleteCommandUsing = "using $currentDirectory.Application.Features.$Controller.Delete;"
    
    $deleteEndpoint = "[HttpDelete]
     public async Task<IActionResult> Delete$Controller(CancellationToken ct)
     {
        $deleteCommandClass command = new ();
        return Ok(await _mediator.Send(command, ct));
     }
    "
   
    #HANDLER

    $deleteMediatorPath = ".\$currentDirectory.Application\Features\$controller\Delete"
    New-Item -Path $deleteMediatorPath -ItemType Directory > $null

    $MediatorFilePath = ".\$currentDirectory.Application\Features\$controller\Delete\$deleteCommandClass.cs"

    $Data = "using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace $currentDirectory.Application.Features.$controller.Delete;

public class $deleteCommandClass : IRequest<bool>
{
}

internal class $deleteCommandHandlerClass : IRequestHandler<$deleteCommandClass,bool>
{
    public $deleteCommandHandlerClass()
    {
    
    }   
    
    public async Task<bool> Handle($deleteCommandClass request, CancellationToken ct)
    {
	    return true;
    }
}

    "

    Set-Content -Path $MediatorFilePath -Value $Data > $null
}

if($selectedOptions.Contains("PUT"))
{
    #Adding extra data
    $PutCommandUsing = "using $currentDirectory.Application.Features.$Controller.Update;"
    
    $putEndpoint = "[HttpPut]
     public async Task<IActionResult> Update$Controller(CancellationToken ct)
     {
        $putCommandClass command = new ();
        return Ok(await _mediator.Send(command, ct));
     } 
    "
   
    #HANDLER
    $putMediatorPath = ".\$currentDirectory.Application\Features\$controller\Update"
    New-Item -Path $putMediatorPath -ItemType Directory > $null

    $MediatorFilePath = ".\$currentDirectory.Application\Features\$controller\Update\$putCommandClass.cs"

    $Data = "using MediatR;
using System.Threading;
using System.Threading.Tasks;

namespace $currentDirectory.Application.Features.$controller.Update;

public class $putCommandClass : IRequest<$mediatorResponseClass>
{
}

public class $putCommandHandlerClass : IRequestHandler<$putCommandClass,$mediatorResponseClass>
{
    public $putCommandHandlerClass()
    {
    
    }

    public async Task<$mediatorResponseClass> Handle($putCommandClass request, CancellationToken ct)
    {
	     return new $mediatorResponseClass();
    }
}

    "

    Set-Content -Path $MediatorFilePath -Value $Data > $null
}

$controllerData = "
using AutoMapper;
using $currentDirectory.Api.Shared;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using System.Threading;
using System.Threading.Tasks;
$GetCommandUsing
$PostCommandUsing
$deleteCommandUsing
$putCommandUsing

namespace $currentDirectory.Api.Features.$controller;

public class $controllerClass : BaseApiController
{
	private readonly IMediator _mediator;
	private readonly IMapper _mapper;

	public $controllerClass (IMediator mediator, IMapper mapper)
	{
		_mediator = mediator;
	  	_mapper = mapper;
	}

    $getEndpoint
    $postEndpoint
    $putEndpoint
    $deleteEndpoint
 }

 "

Set-Content -Path $controllerFilePath -Value $controllerData > $null

Clear-Host

Write-Host "Ok!" -ForegroundColor green

Write-Host "-- $controllerPath D"
Write-Host "  -- $controllerClass.cs"

if($selectedOptions.Contains("GET") -or $selectedOptions.Contains("POST") -or $selectedOptions.Contains("PUT") -or $selectedOptions.Contains("DELETE"))
{
    Write-Host ""
    Write-Host "-- $MediatorPath D"
}

if($selectedOptions.Contains("POST"))
{
    Write-Host "  -- Create D"
    Write-Host "    -- $postCommandClass.cs"
    Write-Host "    -- $postCommandHandlerClass.cs"
}

if($selectedOptions.Contains("DELETE"))
{
    Write-Host "  -- Delete D"
    Write-Host "    -- $deleteCommandClass.cs"
    Write-Host "    -- $deleteCommandHandlerClass.cs"   
}

if($selectedOptions.Contains("GET"))
{
    Write-Host "  -- Get D"
    Write-Host "    -- $GetCommandClass.cs"
    Write-Host "    -- $GetCommandHandlerClass.cs"
}

if($selectedOptions.Contains("PUT"))
{
    Write-Host "  -- Update D"
    Write-Host "    -- $putCommandClass.cs"
    Write-Host "    -- $putCommandHandlerClass.cs"   
}

if($selectedOptions.Contains("GET") -or $selectedOptions.Contains("POST") -or $selectedOptions.Contains("PUT"))
{
    Write-Host "  -- $mediatorResponseClass.cs"
}

