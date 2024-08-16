#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 80
EXPOSE 443


FROM node:18 AS npm
WORKDIR /code
COPY . .
RUN npm install
RUN npm run build-linux-x64


FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /code
COPY --from=npm /code/build-linux-x64 .

RUN dotnet restore ./build.sln
RUN dotnet build ./build.sln -c Release
RUN dotnet publish ./src/SSCMS.Cli/SSCMS.Cli.csproj -c Release -o ./publish
RUN dotnet publish ./src/SSCMS.Web/SSCMS.Web.csproj -c Release -o ./publish
RUN cp -r ./publish/wwwroot ./publish/_wwwroot
RUN echo `date +%Y-%m-%d-%H-%M-%S` > ./publish/_wwwroot/sitefiles/version.txt

FROM base AS final
WORKDIR /app
COPY --from=build /code/publish .
ENTRYPOINT ["dotnet", "SSCMS.Web.dll"]

# docker build -t sscms/core:dev .