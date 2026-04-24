import { useUser, useAuth } from "@clerk/nextjs";
import { useConvexAuth } from "convex/react";
import { useEffect, useState } from "react";
import { useMutation } from "convex/react";
import { api } from "../convex/_generated/api";

export function useStoreUser() {
  const { isLoading: isConvexLoading } = useConvexAuth();
  const { user } = useUser();
  const { isSignedIn, isLoaded, getToken } = useAuth();
  // When this state is set we know the server
  // has stored the user.
  const [userId, setUserId] = useState(null);
  const storeUser = useMutation(api.users.store);

  // DEBUGGING: Log the raw token payload to the console
  useEffect(() => {
    async function debugToken() {
      try {
        const token = await getToken({ template: "convex" });
        if (token) {
          const payload = JSON.parse(atob(token.split('.')[1]));
          console.log("🔥 JWT PAYLOAD:", payload);
        } else {
          console.log("🔥 NO TOKEN RETURNED FROM CLERK!");
        }
      } catch (e) {
        console.error("🔥 TOKEN FETCH ERROR:", e);
      }
    }
    if (isSignedIn) {
      debugToken();
    }
  }, [isSignedIn, getToken]);

  // Call the `storeUser` mutation function to store
  // the current user in the `users` table and return the `Id` value.
  useEffect(() => {
    // If the user is not logged in don't do anything
    if (!isSignedIn) {
      return;
    }
    // Store the user in the database.
    // Recall that `storeUser` gets the user information via the `auth`
    // object on the server. You don't need to pass anything manually here.
    async function createUser() {
      if (!user) return;
      const id = await storeUser({
        clerkId: user.id,
        email: user.primaryEmailAddress?.emailAddress || "",
        name: user.fullName || "Anonymous",
        pictureUrl: user.imageUrl || "",
      });
      setUserId(id);
    }
    createUser();
    return () => setUserId(null);
    // Make sure the effect reruns if the user logs in with
    // a different identity
  }, [isSignedIn, storeUser, user?.id]);
  // Combine the local state with the state from context
  return {
    isLoading: isConvexLoading || !isLoaded || (isSignedIn && userId === null),
    isAuthenticated: isSignedIn && userId !== null,
  };
}
