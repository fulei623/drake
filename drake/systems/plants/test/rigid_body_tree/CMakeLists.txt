pods_find_pkg_config(bullet)

if(bullet_FOUND)
  add_executable(rbt_collisions_test rbt_collisions_test.cc)
  target_link_libraries(rbt_collisions_test drakeRBM ${GTEST_BOTH_LIBRARIES})
  add_test(NAME rbt_collisions_test COMMAND rbt_collisions_test)
endif()

add_executable(rigid_body_tree_test rigid_body_tree_test.cc)
target_link_libraries(rigid_body_tree_test drakeRBSystem ${GTEST_BOTH_LIBRARIES})
add_test(NAME rigid_body_tree_test COMMAND rigid_body_tree_test)

