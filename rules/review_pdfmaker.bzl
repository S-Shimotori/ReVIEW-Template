def _review_pdfmaker_impl(ctx):
    pdf_name = ctx.attr.output + ".pdf"
    pdf = ctx.actions.declare_file(pdf_name)

    project_directory_path = ""
    if len(ctx.file.config.path.split("/")) > 1:
        project_directory_path = "/".join(ctx.file.config.path.split("/")[:-1])
    contents_directory_path = project_directory_path
    if ctx.attr.contentdir != None and len(ctx.attr.contentdir) > 0:
        contents_directory_path = project_directory_path + "/" + ctx.attr.contentdir if len(project_directory_path) > 0 else ctx.attr.contentdir
    images_directory_path = project_directory_path + "/images" if len(project_directory_path) > 0 else "images"
    sty_directory_path = project_directory_path + "/sty" if len(project_directory_path) > 0 else "sty"

    tmp_directory_path = "/private/var/tmp/build_%s" % ctx.attr.name
    working_directory_path_variable = "WORKING_DIRECTORY_PATH"

    command_export_working_directory_path = "export %s=$(pwd)" % working_directory_path_variable
    command_remove_tmp_directory = "rm -rf %s" % tmp_directory_path
    command_make_tmp_directory = "mkdir %s" % tmp_directory_path

    command_cp_files = []
    for content in ctx.files.contents:
        command_cp_files += ["cp %s %s/%s/" % (content.path, tmp_directory_path, ctx.attr.contentdir)]
    for yaml in ctx.files.yamls + [ctx.file.config]:
        command_cp_files += ["cp %s %s" % (yaml.path, tmp_directory_path)]
    command_cp_files += ["mkdir %s/images" % tmp_directory_path]
    for image in ctx.files.images:
        if image.extension in ["ai", "eps", "pdf", "tif", "tiff", "png", "bmp", "jpg", "jpeg", "gif"]:
            if image.path.startswith(images_directory_path):
                dest = image.dirname
                if len(project_directory_path) > 0:
                    dest = dest.replace(project_directory_path, "", 1)
                command_cp_files += ["mkdir -p %s/%s" % (tmp_directory_path, dest)]
                command_cp_files += ["cp %s %s/%s" % (image.path, tmp_directory_path, dest)]
            else:
                command_cp_files += ["cp %s %s/images/" % (image.path, tmp_directory_path)]
        else:
            fail("Re:View doesn't support image file <%s>" % image.basename)
    command_cp_files += ["mkdir %s/sty" % tmp_directory_path]
    for sty in ctx.files.sty:
        if sty.path.startswith(sty_directory_path):
            dest = sty.dirname
            if len(project_directory_path) > 0:
                dest = dest.replace(project_directory_path, "", 1)
            command_cp_files += ["mkdir -p %s/%s" % (tmp_directory_path, dest)]
            command_cp_files += ["cp %s %s/%s" % (sty.path, tmp_directory_path, dest)]
        else:
            command_cp_files += ["cp %s %s/sty/" % (sty.path, tmp_directory_path)]

    command_cd_tmp = "cd %s" % tmp_directory_path
    command_review_pdfmaker = "review-pdfmaker %s" % ctx.file.config.basename
    command_cd_working = "cd $%s" % working_directory_path_variable
    command_copy_output = "cp %s/%s %s" % (tmp_directory_path, pdf_name, pdf.path)

    commands = [
        command_export_working_directory_path,
        command_remove_tmp_directory,
        command_make_tmp_directory
    ]
    commands += command_cp_files
    commands += [
        command_cd_tmp,
        command_review_pdfmaker,
        command_cd_working,
        command_copy_output
    ]

    ctx.actions.run_shell(
        outputs = [pdf],
        inputs = [ctx.file.config] + ctx.files.contents + ctx.files.yamls + ctx.files.images + ctx.files.sty,
        command = " && ".join(commands),
        use_default_shell_env = True
    )
    return [DefaultInfo(files = depset([pdf]))]

review_pdfmaker = rule(
    implementation = _review_pdfmaker_impl,
    attrs = {
        "output": attr.string(
            mandatory = True,
            doc = "bookname in config.yml"
        ),
        "config": attr.label(
            allow_single_file = True,
            default = ":config.yml",
            doc = "Config file."
        ),
        "contents": attr.label_list(
            allow_files = True,
            doc = """
RE files.
Files will be placed under the project root directory. Or set contentdir if you need.
"""
        ),
        "yamls": attr.label_list(
            allow_files = True,
            doc = """
YAML files.
Files will be placed under the project root directory.
"""
        ),
        "contentdir": attr.string(
            doc = "contentdir in config.yml"
        ),
        "images": attr.label_list(
            allow_files = True,
            doc = """
Images files.
Files not in the image directory will be placed under images/.
"""
        ),
        "sty": attr.label_list(
            allow_files = True,
            doc = """
Style files and class files.
Files will be placed under sty/.
"""
        )
    }
)
