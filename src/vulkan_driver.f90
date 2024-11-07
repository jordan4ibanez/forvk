module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_init
  use :: glfw
  use :: string_f90
  use :: vector
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.
  !
  ! todo: this has a lot of memory leaks which will need to be tested with valgrind to fix.


  ! VkInstance
  integer(c_int64_t), target :: vulkan_instance = VK_NULL_HANDLE

  ! VkDebugUtilsMessengerEXT
  integer(c_int64_t), target :: debug_messenger = VK_NULL_HANDLE

  ! VkPhysicalDevice
  integer(c_int64_t), target :: physical_device = VK_NULL_HANDLE

  ! Controls debugging output.
  logical(c_bool), parameter :: DEBUG_MODE = .true.


contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


!* INITIALIZATION. ====================================================================


  subroutine init_vulkan()
    implicit none

    ! VkApplicationInfo
    type(vk_application_info), pointer :: app_info
    ! VkInstanceCreateInfo
    type(vk_instance_create_info), pointer :: vulkan_create_info
    ! const char **
    type(vec) :: required_extensions
    ! const char **
    type(vec) :: required_validation_layers
    type(vk_debug_utils_messenger_create_info_ext), pointer :: debug_messenger_create_info
    !* Note: this will go out of scope after this. We only need it for pre-initialization.
    type(vk_debug_utils_messenger_create_info_ext) :: before_init_messenger_create_info

    !? This is how to get from these vectors. (char ** array underneath)
    !? do i = 1,int(validation_layers%size())
    !   !! NOTICE: Redirecting the pointer with c_f_pointer here!
    !?   call c_f_pointer(validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
    !?   required_layer => string_from_c(raw_c_ptr_ptr)
    !?   print*,required_layer
    !? end do

    call create_glfw()

    call create_app_info(app_info)

    call create_required_extensions(required_extensions, DEBUG_MODE)

    call ensure_extensions_present(required_extensions)

    call create_required_validation_layers(required_validation_layers, DEBUG_MODE)

    call ensure_validation_layer_support(required_validation_layers, DEBUG_MODE)

    call create_vulkan_instance_create_info(vulkan_create_info, app_info, required_extensions, required_validation_layers, before_init_messenger_create_info, DEBUG_MODE)

    call create_vulkan_instance(vulkan_create_info, vulkan_instance)

    call setup_debug_messenger(debug_messenger_create_info, vulkan_instance, debug_messenger, DEBUG_MODE)

    ! TODO: THIS SHOULD BE BROKEN UP INTO ANOTHER FUNCTION THAT SELECTS PHYSICAL DEVICE!
    ! TODO: OR, MAKE A GREEN SPACER INSIDE THE FILE TO DENOTE WHERE PHYSICAL DEVICE SELECTION STARTS.
    !! PROBABLY SHOULD DO THE SAME THING WHICH EACH STEP IN INITIALIZATION !!

    call pick_physical_device()

    ! todo: deallocate any pointers inside.
    deallocate(app_info)
    deallocate(vulkan_create_info)

  end subroutine init_vulkan


  subroutine pick_physical_device()
    implicit none

    integer(c_int32_t) :: device_count, i
    ! c_int64_t [VkPhysicalDevice]
    type(vec) :: available_devices
    ! VkPhysicalDevice
    integer(c_int64_t) :: device
    ! VkPhysicalDevice *
    integer(c_int64_t), pointer :: device_pointer

    device = 0

    ! First, we will get the available devices from Vulkan.
    if (vk_enumerate_physical_devices(vulkan_instance, device_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate physical devices."
    end if

    if (device_count == 0) then
      ! todo: in Formine we will make this clean up then run the OpenGL driver. :)
      error stop "[Vulkan] Error: No GPU with Vulkan support available."
    end if

    ! Now, create the vector to store the data.
    available_devices = new_vec(sizeof(device), int(device_count, c_int64_t))
    call available_devices%resize(int(device_count, c_int64_t), device)

    ! Here we're passing in the underlying C array.
    if (vk_enumerate_physical_devices(vulkan_instance, device_count, available_devices%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate physical devices."
    end if

    ! Let's find a device that's suitable.
    device_search: do i = 1,int(available_devices%size())
      ! We're inlining transfering the device pointer from the interal C array into Fortran.
      call c_f_pointer(available_devices%get(int(i, c_int64_t)), device_pointer)

      ! We found it, woo. That's our physical device.
      ! todo: Make a menu option to select another physical device.
      if (device_is_suitable(device_pointer)) then
        physical_device = device_pointer
        exit device_search
      end if
    end do device_search

    if (physical_device == VK_NULL_HANDLE) then
      error stop "[Vulkan] Error: No suitable GPU available."
    end if
  end subroutine pick_physical_device


  function device_is_suitable(device_pointer) result(suitable)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), pointer :: device_pointer
    logical(c_bool) :: suitable
    type(vk_physical_device_properties), pointer :: device_properties
    type(vk_physical_device_features), pointer :: device_features

    suitable = .false.

    allocate(device_properties)
    call vk_get_physical_device_properties(device_pointer, c_loc(device_properties))

    allocate(device_features)
    call vk_get_physical_device_features(device_pointer, c_loc(device_features))

    ! Check if we have the bare minimum to run with.
    ! todo: score GPUs.
    ! todo: device_properties%device_type == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU .and.
    ! todo: https://vulkan-tutorial.com/Drawing_a_triangle/Setup/Physical_devices_and_queue_families
    ! todo: Base device suitability checks
    ! if (device_features%geometry_shader == VK_TRUE) then
    suitable = .true.
    ! end if

    deallocate(device_properties)
    deallocate(device_features)

  end function device_is_suitable


!* MAIN LOOP. ====================================================================


  subroutine main_loop()
    implicit none

    ! do while(.not. glfw_window_should_close())
    !   call glfw_poll_events()
    ! end do

  end subroutine main_loop


!* CLEAN UP. ====================================================================

  subroutine clean_up()
    implicit none

    if (DEBUG_MODE) then
      call forvulkan_destroy_debug_utils_messenger_ext(vulkan_instance, debug_messenger, c_null_ptr)
    end if

    print"(A)","[Vulkan]: Destroying instance."

    call vk_destroy_instance(vulkan_instance, c_null_ptr)

    call glfw_destroy_window()

    call glfw_terminate()
  end subroutine clean_up


end module vulkan_driver
