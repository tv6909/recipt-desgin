"use server"

import { createClient } from "@/lib/supabase/server"
import { revalidatePath } from "next/cache"

export async function createUser(formData: {
  email: string
  password: string
  role: "seller" | "viewer"
  permissions: any
}) {
  try {
    const supabase = await createClient()

    // Get current user to verify admin permissions
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      throw new Error("Authentication required")
    }

    // Check if current user is admin
    const { data: profile, error: profileError } = await supabase
      .from("user_profiles")
      .select("role")
      .eq("id", user.id)
      .single()

    if (profileError || profile?.role !== "admin") {
      throw new Error("Admin privileges required")
    }

    const supabaseAdmin = await createClient(true)

    const { data: authData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email: formData.email,
      password: formData.password,
      email_confirm: true,
    })

    if (createError) throw createError

    if (authData.user) {
      const { error: profileError } = await supabase.from("user_profiles").insert({
        id: authData.user.id,
        email: formData.email,
        role: formData.role,
        permissions: formData.role === "seller" ? formData.permissions : {},
        created_by: user.id,
      })

      if (profileError) throw profileError
    }

    revalidatePath("/admin/users")
    return { success: true }
  } catch (error: any) {
    console.error("Error creating user:", error)
    return { success: false, error: error.message }
  }
}
