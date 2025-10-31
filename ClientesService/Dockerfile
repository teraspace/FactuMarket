# Etapa de build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ClientesService.csproj ./
RUN dotnet restore ClientesService.csproj

COPY . ./
RUN dotnet publish ClientesService.csproj -c Release -o /app/publish

# Etapa de runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 5001
ENTRYPOINT ["dotnet", "ClientesService.dll"]
