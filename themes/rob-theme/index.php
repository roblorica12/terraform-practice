<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title><?php bloginfo('name'); ?></title>
  <link rel="stylesheet" href="<?php echo get_stylesheet_uri(); ?>">
</head>
<body>
  <h1>Rob Theme v1</h1>
  <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
    <h2><?php the_title(); ?></h2>
    <?php the_content(); ?>
  <?php endwhile; endif; ?>
</body>
</html>