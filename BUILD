load(":rules/review_pdfmaker.bzl", "review_pdfmaker")

review_pdfmaker(
    name = "pdf",
    output = "ReVIEW-Template.pdf",
    config = ":articles/config.yml",
    ymls = glob(
        ["articles/*.yml"],
        exclude = ["articles/config-ebook.yml"]
    ),
    srcs = glob(["articles/**/*.re"]),
    images = glob(["articles/images/**"]),
    sty = glob([
        "articles/sty/*.sty",
        "articles/sty/*.cls",
    ]),
)

review_pdfmaker(
    name = "pdf-ebook",
    output = "ReVIEW-Template-ebook.pdf",
    config = ":articles/config-ebook.yml",
    ymls = glob(["articles/*.yml"]),
    srcs = glob(["articles/**/*.re"]),
    images = glob(["articles/images/**"]),
    sty = glob([
        "articles/sty/*.sty",
        "articles/sty/*.cls",
    ]),
)
