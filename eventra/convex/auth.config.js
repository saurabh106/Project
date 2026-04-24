export default {
  providers: [
    {
      domain: "https://many-arachnid-54.clerk.accounts.dev/",
      applicationID: "convex",
    },
    {
      domain: "https://many-arachnid-54.clerk.accounts.dev",
      applicationID: "convex",
    },
    {
      domain: process.env.CLERK_JWT_ISSUER_DOMAIN || "",
      applicationID: "convex",
    }
  ],
};
