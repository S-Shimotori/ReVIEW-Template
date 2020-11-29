load(":rules/review_pdfmaker.bzl", "review_pdfmaker")

contents = glob([
    "articles/**/*.re"
])

images = glob([
    "articles/images/**/*.ai",
    "articles/images/**/*.png"
])

sty = glob([
    "articles/sty/*.sty",
    "articles/sty/*.cls",
])

review_pdfmaker(
    name = "pdf",
    output = "ReVIEW-Template",
    config = ":articles/config.yml",
    yamls = glob(
        ["articles/*.yml"],
        exclude = ["articles/config-ebook.yml"]
    ),
    contents = contents,
    images = images,
    sty = sty,
)

review_pdfmaker(
    name = "pdf-ebook",
    output = "ReVIEW-Template-ebook",
    config = ":articles/config-ebook.yml",
    yamls = glob(["articles/*.yml"]),
    contents = contents,
    images = images,
    sty = sty,
)
