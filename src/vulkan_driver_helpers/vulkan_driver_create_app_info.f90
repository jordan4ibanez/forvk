module vulkan_driver_create_app_info
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_app_info(app_info, app_name, engine_name)
    implicit none

    type(vk_application_info), intent(inout) :: app_info
    character(len = :, kind = c_char), intent(in), pointer :: app_name, engine_name

    print"(A)","[Vulkan]: Creating app info."

    app_info%s_type = VK_STRUCTURE_TYPE%APPLICATION_INFO

    app_info%p_application_name = c_loc(app_name)
    app_info%application_version = vk_make_api_version(0,1,0,0)
    app_info%p_engine_name = c_loc(engine_name)
    app_info%engine_version = vk_make_api_version(0,1,0,0)
    app_info%api_version = VK_API_VERSION_1_0
  end subroutine create_app_info


end module vulkan_driver_create_app_info
