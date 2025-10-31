FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /app

COPY Clientes.csproj ./
RUN dotnet restore

COPY . .

ENV ASPNETCORE_URLS=http://0.0.0.0:5001

EXPOSE 5001

CMD ["dotnet", "run", "--urls", "http://0.0.0.0:5001"]
