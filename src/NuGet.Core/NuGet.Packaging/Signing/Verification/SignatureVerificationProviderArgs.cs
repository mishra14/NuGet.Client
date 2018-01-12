// Copyright (c) .NET Foundation. All rights reserved.
// Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.

using System;
using System.Collections.Generic;

namespace NuGet.Packaging.Signing
{
    public class SignatureVerificationProviderArgs
    {
        public IEnumerable<NuGetSignatureWhitelistObject> Whitelist { get; }

        public SignatureVerificationProviderArgs()
        {
        }

        public SignatureVerificationProviderArgs(IEnumerable<NuGetSignatureWhitelistObject> whitelist)
        {
            Whitelist = whitelist ?? throw new ArgumentNullException(nameof(whitelist));
        }
    }
}
