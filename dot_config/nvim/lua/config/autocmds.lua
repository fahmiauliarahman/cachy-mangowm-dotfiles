vim.filetype.add({
  pattern = {
    [".*/templates/.*%.html"] = function(path)
      if vim.fs.root(path, { "manage.py" }) then
        return "htmldjango"
      end
    end,
    -- docker_compose_language_service only attaches to this compound filetype.
    [".*docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    [".*compose.*%.ya?ml"] = "yaml.docker-compose",
  },
})
