def _review_pdfmaker_impl(ctx):
    pdf = ctx.actions.declare_file(ctx.attr.output)
    inputs = [ctx.file.config] + ctx.files.ymls + ctx.files.srcs + ctx.files.images + ctx.files.sty

    project_directory = "."
    if len(ctx.file.config.path.split("/")) > 1:
        project_directory = "/".join(ctx.file.config.path.split("/")[:-1])
    tmp_directory = "/private/var/tmp/build_%s" % ctx.attr.name
    working_path_variable = "WORKING_%s_PATH" % ctx.attr.name.upper().replace("-", "_")

    command_export_working_path = "export %s=$(pwd)" % working_path_variable
    command_remove_tmp = "rm -rf %s" % tmp_directory
    command_make_tmp = "mkdir %s" % tmp_directory
    command_cd_project = "cd %s" % project_directory
    command_copy_files = "cp -a . %s" % tmp_directory
    command_cd_tmp = "cd %s" % tmp_directory
    command_review_pdfmaker = "review-pdfmaker %s" % ctx.file.config.basename
    command_cd_working = "cd $%s" % working_path_variable
    command_copy_output = "cp %s/%s %s" % (tmp_directory, ctx.attr.output, pdf.path)

    commands = [
        command_export_working_path,
        command_remove_tmp,
        command_make_tmp,
        command_cd_project,
        command_copy_files,
        command_cd_tmp,
        command_review_pdfmaker,
        command_cd_working,
        command_copy_output
    ]

    ctx.actions.run_shell(
        outputs = [pdf],
        inputs = inputs,
        command = " && ".join(commands),
        use_default_shell_env = True
    )
    return [DefaultInfo(files = depset([pdf]))]

review_pdfmaker = rule(
    implementation = _review_pdfmaker_impl,
    attrs = {
        "ymls": attr.label_list(
            allow_files = True
        ),
        "output": attr.string(
            mandatory = True
        ),
        "config": attr.label(
            allow_single_file = True,
            default = ":config.yml"
        ),
        "srcs": attr.label_list(
            allow_files = True
        ),
        "images": attr.label_list(
            allow_files = True
        ),
        "sty": attr.label_list(
            allow_files = True
        )
    }
)
