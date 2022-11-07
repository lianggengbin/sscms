﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NSwag.Annotations;
using SSCMS.Configuration;
using SSCMS.Repositories;
using SSCMS.Services;

namespace SSCMS.Web.Controllers.Admin.Settings.Cloud
{
    [OpenApiIgnore]
    [Authorize(Roles = Types.Roles.Administrator)]
    [Route(Constants.ApiAdminPrefix)]
    public partial class SettingsSmsController : ControllerBase
    {
        private const string Route = "settings/cloudSettingsSms";

        private readonly IAuthManager _authManager;
        private readonly ICloudManager _cloudManager;
        private readonly IConfigRepository _configRepository;

        public SettingsSmsController(IAuthManager authManager, ICloudManager cloudManager, IConfigRepository configRepository)
        {
            _authManager = authManager;
            _cloudManager = cloudManager;
            _configRepository = configRepository;
        }

        public class GetResult
        {
            public bool IsCloudSms { get; set; }
            public bool IsCloudSmsAdministrator { get; set; }
            public bool IsCloudSmsUser { get; set; }
        }

        public class SubmitRequest
        {
            public bool IsCloudSms { get; set; }
            public bool IsCloudSmsAdministrator { get; set; }
            public bool IsCloudSmsUser { get; set; }
        }
    }
}
