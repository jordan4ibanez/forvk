#include <stdlib.h>
#include <vulkan/vulkan_core.h>

VkInstance *grab_vk_instance_pointer()
{
  void *data = malloc(sizeof(VkInstance));

  assert(data);

  return (VkInstance *)data;
}