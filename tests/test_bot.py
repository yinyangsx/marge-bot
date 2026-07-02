# pylint: disable=protected-access
from unittest.mock import MagicMock, patch

import marge.bot
import marge.job


class TestBot:
    def _bot_config(self, **options):
        user = MagicMock(is_admin=False)
        user.id = 77
        return marge.bot.BotConfig(
            user=user,
            use_https=False,
            auth_token=None,
            ssh_key_file=None,
            project_regexp=None,
            merge_order='assigned_at',
            merge_opts=marge.job.MergeJobOptions.default(
                target_branch_health_check=True,
                oncall_fix_label='oncall fix',
                **options
            ),
            git_timeout=None,
            git_reference_repo=None,
            branch_regexp=None,
            source_branch_regexp=None,
            batch=False,
            cli=True,
        )

    def _merge_request(self, iid, labels=None):
        merge_request = MagicMock()
        merge_request.iid = iid
        merge_request.labels = labels or []
        merge_request.target_project_id = 1234
        merge_request.target_branch = 'master'
        return merge_request

    def test_single_mode_scans_for_oncall_fix(self):
        bot = marge.bot.Bot(api=MagicMock(), config=self._bot_config())
        project = MagicMock()
        repo = MagicMock()
        repo_manager = MagicMock()
        repo_manager.repo_for_project.return_value = repo
        merge_requests = [
            self._merge_request(1),
            self._merge_request(2),
            self._merge_request(3, labels=['oncall fix']),
        ]

        with patch('marge.bot.job.MergeJob.get_target_branch_ci_status') as target_ci_status:
            target_ci_status.return_value = 'failed'
            with patch.object(bot, '_get_single_job') as get_single_job:
                single_job = MagicMock()
                get_single_job.return_value = single_job

                bot._process_merge_requests(repo_manager, project, merge_requests)

        get_single_job.assert_called_once_with(
            project=project,
            merge_request=merge_requests[2],
            repo=repo,
            options=bot._config.merge_opts,
        )
        single_job.execute.assert_called_once_with()
        assert target_ci_status.call_count == 2

    def test_single_mode_skips_failed_target(self):
        bot = marge.bot.Bot(api=MagicMock(), config=self._bot_config())
        project = MagicMock()
        repo = MagicMock()
        repo_manager = MagicMock()
        repo_manager.repo_for_project.return_value = repo
        merge_requests = [
            self._merge_request(1),
            self._merge_request(2),
        ]

        with patch('marge.bot.job.MergeJob.get_target_branch_ci_status') as target_ci_status:
            target_ci_status.return_value = 'failed'
            with patch.object(bot, '_get_single_job') as get_single_job:
                bot._process_merge_requests(repo_manager, project, merge_requests)

        get_single_job.assert_not_called()
        assert target_ci_status.call_count == 2
