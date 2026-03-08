        ;; 高亮 Go 單行註解中的 Swagger 標籤
        ((line_comment) @swagger_tag
          (#match? @swagger_tag "@Summary|@Description|@Tags|@Accept|@Produce|@Param|@Success|@Failure|@Router|@Security"))

        ;; 高亮 Go 區塊註解中的 Swagger 標籤
        ((comment_block) @swagger_tag
          (#match? @swagger_tag "@Summary|@Description|@Tags|@Accept|@Produce|@Param|@Success|@Failure|@Router|@Security"))
      