from datetime import datetime
from pathlib import Path
from visualisation.plots_figures import generate_word_cloud, drc_flag_color_map
from visualisation.terms_count import get_term_count


def generate_today_word_cloud(path='images/'):
    """
    generate today word cloud

    Args:
        path (str, optional): [description]. Defaults to 'images/'.
    """
    terms_counts = get_term_count()
    word_cloud = generate_word_cloud(terms_counts, drc_flag_color_map)
    word_cloud_path = Path.cwd().joinpath(
        path, 'word_cloud', datetime.today().strftime('%m-%d-%Y'))
    word_cloud.to_file(word_cloud_path)
    return word_cloud_path
