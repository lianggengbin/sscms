#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 80
EXPOSE 443


FROM node:18 AS npm
# 定义构建时变量
ARG OS_VERSION
ARG APP_VERSION
WORKDIR /code
COPY . .
RUN npm install
RUN npm run build-${OS_VERSION}


FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG OS_VERSION
ARG APP_VERSION
WORKDIR /code
COPY --from=npm /code .

RUN dotnet restore ./build-${OS_VERSION}/build.sln
RUN dotnet build ./build-${OS_VERSION}/build.sln -c Release
RUN dotnet publish ./build-${OS_VERSION}/src/SSCMS.Cli/SSCMS.Cli.csproj -c Release -o ./publish/sscms-${APP_VERSION}-${OS_VERSION}
RUN dotnet publish ./build-${OS_VERSION}/src/SSCMS.Web/SSCMS.Web.csproj -c Release -o ./publish/sscms-${APP_VERSION}-${OS_VERSION}

FROM npm AS copyfile
ARG OS_VERSION
ARG APP_VERSION
WORKDIR /code
COPY --from=build /code .
RUN npm run copy-${OS_VERSION}
RUN cp -r ./publish/sscms-${APP_VERSION}-${OS_VERSION}/wwwroot ./publish/sscms-${APP_VERSION}-${OS_VERSION}/_wwwroot
RUN ls ./publish/sscms-${APP_VERSION}-${OS_VERSION}
RUN echo `date +%Y-%m-%d-%H-%M-%S` > ./publish/sscms-${APP_VERSION}-${OS_VERSION}/_wwwroot/sitefiles/version.txt

FROM base AS final
ARG OS_VERSION
ARG APP_VERSION
WORKDIR /app
COPY --from=copyfile /code/publish/sscms-${APP_VERSION}-${OS_VERSION} .
ENTRYPOINT ["dotnet", "SSCMS.Web.dll"]

# docker build -t sscms/core:dev .