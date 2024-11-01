#include <stdlib.h>
#include <assert.h>
#include <vulkan/vulkan_core.h>

VkInstance *forvk_grab_instance_pointer()
{
  void *data = malloc(sizeof(VkInstance));

  assert(data);

  return (VkInstance *)data;
}

void forvk_destroy_pointer_instance(VkInstance *instance)
{
  // We're not using any custom allocators with this because that would be a nightmare.
  vkDestroyInstance(*instance, NULL);
}